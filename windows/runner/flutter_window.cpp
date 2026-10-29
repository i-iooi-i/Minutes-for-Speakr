#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

namespace {
// Posted by a second instance of speakr_app.exe (see windows/runner/main.cpp)
// to ask the running primary to surface its main window. WM_APP + 1 is the
// tray callback (tray_icon.cpp), so this uses + 2.
constexpr UINT kShowInstanceMessage = WM_APP + 2;

constexpr wchar_t kWindowPrefs[] = L"Software\\MinutesForSpeakr";
void SaveWindowPlacement(HWND hwnd) {
  WINDOWPLACEMENT placement{sizeof(WINDOWPLACEMENT)};
  if (!GetWindowPlacement(hwnd, &placement)) return;
  // Minimized state must never cause the next launch to open invisibly.
  if (placement.showCmd == SW_SHOWMINIMIZED) {
    placement.showCmd = (placement.flags & WPF_RESTORETOMAXIMIZED) ? SW_SHOWMAXIMIZED : SW_SHOWNORMAL;
  }
  placement.flags = 0;
  HKEY key;
  if (RegCreateKeyExW(HKEY_CURRENT_USER, kWindowPrefs, 0, nullptr, 0,
      KEY_SET_VALUE, nullptr, &key, nullptr) == ERROR_SUCCESS) {
    RegSetValueExW(key, L"Placement", 0, REG_BINARY,
      reinterpret_cast<const BYTE*>(&placement), sizeof(placement));
    RegCloseKey(key);
  }
}
void RestoreWindowPlacement(HWND hwnd, bool hidden) {
  WINDOWPLACEMENT placement{sizeof(WINDOWPLACEMENT)};
  DWORD size = sizeof(placement);
  if (RegGetValueW(HKEY_CURRENT_USER, kWindowPrefs, L"Placement", RRF_RT_REG_BINARY,
      nullptr, &placement, &size) != ERROR_SUCCESS || size != sizeof(placement)) return;
  if (placement.rcNormalPosition.right <= placement.rcNormalPosition.left ||
      placement.rcNormalPosition.bottom <= placement.rcNormalPosition.top) return;
  placement.length = sizeof(placement);
  placement.flags = 0;
  placement.showCmd = placement.showCmd == SW_SHOWMAXIMIZED ? SW_SHOWMAXIMIZED : SW_SHOWNORMAL;
  // SetWindowPlacement adjusts an off-screen saved rectangle to a connected monitor.
  if (hidden) placement.showCmd = SW_HIDE;
  SetWindowPlacement(hwnd, &placement);
}

void BringWindowToForegroundImpl(HWND hwnd) {
  if (hwnd == nullptr) return;
  ::ShowWindow(hwnd, SW_SHOW);
  if (::IsIconic(hwnd)) {
    ::ShowWindow(hwnd, SW_RESTORE);
  }
  ::SetForegroundWindow(hwnd);
}
}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project,
                             bool start_hidden)
    : project_(project), start_hidden_(start_hidden) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  mini_window_native_ = std::make_unique<MiniWindowNative>(
      flutter_controller_->engine(), GetHandle());
  audio_recorder_ =
      std::make_unique<SpeakrAudioRecorder>(flutter_controller_->engine());

  // Outbound channel for tray-driven actions that need to call into Dart
  // (e.g. starting a recording from the tray menu). The Dart side
  // registers a handler in lib/services/tray/tray_bridge.dart.
  tray_channel_ = std::make_unique<
      flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(),
      "speakr/tray",
      &flutter::StandardMethodCodec::GetInstance());

  autostart_channel_ = std::make_unique<AutoStartChannel>(
      flutter_controller_->engine()->messenger());

  // Tray icon: closing the main window hides it; the only real exit is the
  // tray's "Exit" menu item. Captures `this` because the callbacks are only
  // ever fired while the FlutterWindow is alive (TrayIcon is owned by it
  // and reset in OnDestroy).
  tray_icon_ = std::make_unique<TrayIcon>();
  tray_icon_->on_show_requested = [this]() {
    BringWindowToForegroundImpl(GetHandle());
  };
  tray_icon_->on_start_recording_requested = [this]() {
    if (tray_channel_) {
      tray_channel_->InvokeMethod("startRecording", nullptr);
    }
  };
  tray_icon_->on_exit_requested = [this]() { RequestExit(); };
  tray_icon_->Install(GetHandle());
  tray_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "setLanguage") {
          const auto* language = call.arguments()
              ? std::get_if<std::string>(call.arguments()) : nullptr;
          if (tray_icon_ && language) {
            tray_icon_->SetChinese(*language == "zh");
          }
          result->Success();
        } else if (call.method_name() == "setAppearance") {
          const auto* dark = call.arguments()
              ? std::get_if<bool>(call.arguments()) : nullptr;
          if (dark) {
            SetDarkMode(*dark);
            result->Success();
          } else {
            result->Error("invalid-appearance", "Expected a dark mode boolean");
          }
        } else {
          result->NotImplemented();
        }
      });


  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    RestoreWindowPlacement(GetHandle(), start_hidden_);
    if (!start_hidden_) ShowWindow(GetHandle(), SW_SHOW);
    window_prefs_ready_ = true;
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  tray_icon_.reset();
  autostart_channel_.reset();
  tray_channel_.reset();
  audio_recorder_.reset();
  mini_window_native_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

void FlutterWindow::RequestExit() {
  SaveWindowPlacement(GetHandle());
  force_quit_ = true;
  if (tray_icon_) {
    tray_icon_->Remove();
  }
  // Re-arm the base class's quit-on-close so WM_DESTROY posts WM_QUIT and
  // the message loop in main.cpp drains cleanly.
  SetQuitOnClose(true);
  HWND hwnd = GetHandle();
  if (hwnd != nullptr) {
    DestroyWindow(hwnd);
  }
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (window_prefs_ready_ && (message == WM_EXITSIZEMOVE || message == WM_CLOSE ||
      (message == WM_SIZE && (wparam == SIZE_MAXIMIZED || wparam == SIZE_RESTORED) && IsWindowVisible(hwnd)))) {
    SaveWindowPlacement(hwnd);
  }
  // Wake-up message from a second-instance launch — surface the main window.
  if (message == kShowInstanceMessage) {
    BringWindowToForegroundImpl(hwnd);
    return 0;
  }

  // Tray callbacks (private WM_APP message), TaskbarCreated re-add, and
  // WM_COMMAND from the popup menu are all unique to this app and would
  // never be consumed by Flutter or the mini-window helper. Handle them
  // first so neither of those layers sees them.
  if (tray_icon_ &&
      tray_icon_->HandleWindowMessage(hwnd, message, wparam, lparam)) {
    return 0;
  }

  // Close-to-tray: the only real exit is RequestExit() (which sets
  // force_quit_ and destroys the window). Everything else — title-bar X,
  // Alt+F4, taskbar context-menu Close — produces WM_CLOSE and hides.
  if (message == WM_CLOSE && !force_quit_) {
    ShowWindow(GetHandle(), SW_HIDE);
    return 0;
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  // Let the mini-window helper consume its retry-apply timer ticks.
  if (mini_window_native_ &&
      mini_window_native_->HandleWindowMessage(hwnd, message, wparam, lparam)) {
    return 0;
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
