#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

#include "audio_recorder.h"
#include "autostart.h"
#include "mini_window_native.h"
#include "tray_icon.h"
#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  // When |start_hidden| is true the window is created but not shown on the
  // first frame — used by --hidden auto-start launches that go straight to
  // the tray.
  explicit FlutterWindow(const flutter::DartProject& project,
                         bool start_hidden = false);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // Tears down the tray icon and destroys the window so the message loop
  // exits. Invoked from the tray "Exit" menu item.
  void RequestExit();

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // Optional helper that drives the always-on-top mini recorder window
  // on Windows. Constructed after RegisterPlugins() in OnCreate().
  std::unique_ptr<MiniWindowNative> mini_window_native_;

  // Owns the WASAPI + Media Foundation recording pipeline. Constructed
  // after the engine boots; method channel speakr.audio/recorder.
  std::unique_ptr<SpeakrAudioRecorder> audio_recorder_;

  // Owns the system-tray icon. Constructed after the HWND exists.
  std::unique_ptr<TrayIcon> tray_icon_;

  // Outbound channel from native to Dart. Used by tray menu actions that
  // need to call into the running Flutter app (e.g. starting a recording).
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      tray_channel_;

  // Inbound channel from Dart that lets the Settings screen toggle the
  // per-user Windows Run key registration.
  std::unique_ptr<AutoStartChannel> autostart_channel_;

  // True once a real exit has been requested (tray "Exit"). While false,
  // WM_CLOSE hides the window instead of destroying it.
  bool force_quit_ = false;

  // When true the first-frame callback skips Show() so an auto-start
  // launch goes straight to the tray.
  bool start_hidden_ = false;
  bool window_prefs_ready_ = false;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
