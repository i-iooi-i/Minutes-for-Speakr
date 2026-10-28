#ifndef RUNNER_TRAY_ICON_H_
#define RUNNER_TRAY_ICON_H_

#include <windows.h>
#include <shellapi.h>

#include <functional>

// Manages a single Shell_NotifyIcon tray entry tied to the main window. Owns
// the popup menu shown on right-click and translates tray callback messages
// into high-level callbacks (show, exit). The owner HWND is the message sink
// that receives tray notifications and WM_COMMAND dispatches from the menu.
class TrayIcon {
 public:
  TrayIcon();
  ~TrayIcon();

  TrayIcon(const TrayIcon&) = delete;
  TrayIcon& operator=(const TrayIcon&) = delete;

  // Adds the tray icon. Call once after the owner HWND exists.
  bool Install(HWND owner);

  // Removes the tray icon. Safe to call multiple times.
  void Remove();

  void SetChinese(bool enabled) { chinese_ = enabled; }

  // Routes a window message destined for the owner HWND. Returns true when the
  // message was consumed (tray callback, WM_COMMAND for our menu items, or the
  // TaskbarCreated broadcast that follows an Explorer restart).
  bool HandleWindowMessage(HWND hwnd, UINT message, WPARAM wparam,
                           LPARAM lparam);

  // Fired when the user left-clicks/double-clicks the tray icon or selects the
  // "Show Speakr" menu entry.
  std::function<void()> on_show_requested;

  // Fired when the user selects the "Start Recording" menu entry.
  std::function<void()> on_start_recording_requested;

  // Fired when the user selects the "Exit" menu entry.
  std::function<void()> on_exit_requested;

 private:
  void ShowContextMenu(HWND owner);

  bool chinese_ = true;
  HWND owner_ = nullptr;
  bool installed_ = false;
  UINT taskbar_created_msg_ = 0;
};

#endif  // RUNNER_TRAY_ICON_H_
