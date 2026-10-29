#include "tray_icon.h"

#include "resource.h"

namespace {

// Private callback message id for Shell_NotifyIcon. Must be in the WM_APP
// range so it never collides with system messages.
constexpr UINT kTrayCallbackMessage = WM_APP + 1;

// Notification icon identifier. Only one tray icon, so a constant is fine.
constexpr UINT kTrayIconId = 1;

// Popup menu command ids. Defined here (not resource.h) because they are
// only meaningful inside the tray callback path.
constexpr UINT kMenuIdShow = 40001;
constexpr UINT kMenuIdStartRecording = 40003;
constexpr UINT kMenuIdExit = 40002;

}  // namespace

TrayIcon::TrayIcon() = default;

TrayIcon::~TrayIcon() {
  Remove();
}

bool TrayIcon::Install(HWND owner) {
  if (installed_ || owner == nullptr) {
    return installed_;
  }
  owner_ = owner;

  NOTIFYICONDATAW nid = {};
  nid.cbSize = sizeof(nid);
  nid.hWnd = owner_;
  nid.uID = kTrayIconId;
  nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
  nid.uCallbackMessage = kTrayCallbackMessage;
  nid.hIcon = LoadIconW(GetModuleHandleW(nullptr),
                        MAKEINTRESOURCEW(IDI_APP_ICON));
  wcsncpy_s(nid.szTip, L"Mimio", _TRUNCATE);

  if (!Shell_NotifyIconW(NIM_ADD, &nid)) {
    return false;
  }

  nid.uVersion = NOTIFYICON_VERSION_4;
  Shell_NotifyIconW(NIM_SETVERSION, &nid);

  if (taskbar_created_msg_ == 0) {
    taskbar_created_msg_ = RegisterWindowMessageW(L"TaskbarCreated");
  }

  installed_ = true;
  return true;
}

void TrayIcon::Remove() {
  if (!installed_) {
    return;
  }
  NOTIFYICONDATAW nid = {};
  nid.cbSize = sizeof(nid);
  nid.hWnd = owner_;
  nid.uID = kTrayIconId;
  Shell_NotifyIconW(NIM_DELETE, &nid);
  installed_ = false;
}

bool TrayIcon::HandleWindowMessage(HWND hwnd, UINT message, WPARAM wparam,
                                   LPARAM lparam) {
  if (taskbar_created_msg_ != 0 && message == taskbar_created_msg_) {
    // Explorer was restarted; the tray surface is fresh and our icon is
    // gone. Re-add it.
    installed_ = false;
    Install(hwnd);
    return true;
  }

  if (message == kTrayCallbackMessage) {
    const UINT event = LOWORD(lparam);
    if (event == WM_LBUTTONUP || event == WM_LBUTTONDBLCLK) {
      if (on_show_requested) on_show_requested();
    } else if (event == WM_RBUTTONUP || event == WM_CONTEXTMENU) {
      ShowContextMenu(hwnd);
    }
    return true;
  }

  if (message == WM_COMMAND && HIWORD(wparam) == 0) {
    const UINT id = LOWORD(wparam);
    if (id == kMenuIdShow) {
      if (on_show_requested) on_show_requested();
      return true;
    }
    if (id == kMenuIdStartRecording) {
      if (on_start_recording_requested) on_start_recording_requested();
      return true;
    }
    if (id == kMenuIdExit) {
      if (on_exit_requested) on_exit_requested();
      return true;
    }
  }

  return false;
}

void TrayIcon::ShowContextMenu(HWND owner) {
  POINT cursor;
  GetCursorPos(&cursor);

  HMENU menu = CreatePopupMenu();
  if (menu == nullptr) return;

  AppendMenuW(menu, MF_STRING, kMenuIdShow, chinese_ ? L"\u663e\u793a Mimio" : L"Show Mimio");
  AppendMenuW(menu, MF_STRING, kMenuIdStartRecording, chinese_ ? L"\u5f00\u59cb\u5f55\u97f3" : L"Start Recording");
  AppendMenuW(menu, MF_SEPARATOR, 0, nullptr);
  AppendMenuW(menu, MF_STRING, kMenuIdExit, chinese_ ? L"\u9000\u51fa" : L"Exit");

  // TrackPopupMenu requires the owner window to be foreground or the menu
  // won't dismiss when the user clicks elsewhere.
  SetForegroundWindow(owner);

  TrackPopupMenu(menu, TPM_RIGHTBUTTON | TPM_BOTTOMALIGN, cursor.x, cursor.y,
                 0, owner, nullptr);

  // Empty message workaround for TrackPopupMenu's first-click bug.
  PostMessage(owner, WM_NULL, 0, 0);

  DestroyMenu(menu);
}
