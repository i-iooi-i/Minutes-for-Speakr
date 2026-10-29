#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  // `--hidden` is consumed natively (auto-start launches use it to skip the
  // initial window Show()) and not forwarded to Dart.
  bool start_hidden = false;
  for (auto it = command_line_arguments.begin();
       it != command_line_arguments.end();) {
    if (*it == "--hidden") {
      start_hidden = true;
      it = command_line_arguments.erase(it);
    } else {
      ++it;
    }
  }

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  // Single-instance guard. The mini recorder runs as a secondary Flutter
  // engine inside this process, so a process-scoped mutex won't trip on it.
  // The wake message (WM_APP + 2) is handled in flutter_window.cpp.
  HANDLE single_instance_mutex =
      ::CreateMutexW(nullptr, TRUE, L"Local\\SpeakrApp_SingleInstance");
  if (single_instance_mutex != nullptr &&
      ::GetLastError() == ERROR_ALREADY_EXISTS) {
    HWND existing = nullptr;
    for (int i = 0; i < 40 && existing == nullptr; ++i) {
      struct FindCtx { HWND result; } ctx{nullptr};
      ::EnumWindows(
          [](HWND hwnd, LPARAM lp) -> BOOL {
            wchar_t cls[64] = {0};
            if (::GetClassNameW(hwnd, cls, 64) == 0) return TRUE;
            if (::wcscmp(cls, L"FLUTTER_RUNNER_WIN32_WINDOW") != 0) return TRUE;
            if (::GetWindow(hwnd, GW_OWNER) != nullptr) return TRUE;
            if (::GetPropW(hwnd, L"SpeakrMainWindow") == nullptr) return TRUE;
            reinterpret_cast<FindCtx*>(lp)->result = hwnd;
            return FALSE;
          },
          reinterpret_cast<LPARAM>(&ctx));
      existing = ctx.result;
      if (existing == nullptr) ::Sleep(50);
    }
    if (existing != nullptr) {
      ::PostMessageW(existing, WM_APP + 2, 0, 0);
    }
    ::CloseHandle(single_instance_mutex);
    ::CoUninitialize();
    return EXIT_SUCCESS;
  }

  FlutterWindow window(project, start_hidden);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Mimio", origin, size)) {
    return EXIT_FAILURE;
  }
  // Tag the main window so a second-instance launch can find it via
  // EnumWindows even after Dart retitles it (mini_window_native.cpp:107).
  ::SetPropW(window.GetHandle(), L"SpeakrMainWindow",
             reinterpret_cast<HANDLE>(1));
  // Close-to-tray: WM_CLOSE is intercepted in FlutterWindow to hide the
  // window. The tray "Exit" menu item re-arms quit-on-close and destroys
  // the window itself.
  window.SetQuitOnClose(false);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
