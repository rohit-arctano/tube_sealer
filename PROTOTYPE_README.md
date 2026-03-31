# Tube Sealer Resistive Touch UI Prototype

A Flutter-based UI prototype for a resistive-touch tube sealer machine targeting a 5" / 800×480 display with Linux backend. Implements single-source display configuration and responsive scaling for consistent visuals across different device variations.

## What's Implemented

### ✅ Core Features
- **Display Config** (`lib/core/config/display_config.dart`) — Single Dart file to control all UI scaling
- **Responsive Helper** (`lib/core/services/responsive_service.dart`) — Computes scale and touch sizes from config + device metrics
- **Reusable Components** (`lib/widget/components/ui_components.dart`):
  - HeaderBar (timestamp, title, username)
  - ScreenTitle (large screen heading)
  - ProgressPhase (progress bar with label & time)
  - ActionBar (OK/Cancel buttons)
  - IconGrid (3×4 menu with selectable items)
  - SpinBox (dropdown selector with full-screen modal for large touch targets)

### ✅ Priority Screens (Fully Implemented)
1. **Login** (`lib/features/auth/login_screen.dart`) — User selection + numeric password input
2. **Menu** (`lib/features/home/menu_screen.dart`) — 3×4 icon grid with 12 menu functions
3. **Tubing Selection** (`lib/features/run/tubing_selection_screen.dart`) — Type & size selectors
4. **Sealing Process** (`lib/features/sealed_process/sealing_process_screen.dart`) — Live phase progress with Play/Stop controls
5. **Settings** (`lib/features/settings/settings_screen.dart`) — Date/Time, Language, Network Reset

### ✅ Hardware Abstraction
- **Mock Machine** (`lib/core/services/mock_machine.dart`) — Simulates compression, heating, cooling phases with timers
- **Sealing Models** (`lib/core/models/sealing_models.dart`) — Data models for process phases and logs

### ✅ Visual Design
- **Theme**: High-contrast monochrome (dark background #111111, white text)
- **Touch Targets**: 64+ dp minimum for gloved/resistive touch
- **Scaling**: All sizes computed from `displayConfig` baseline (360×640 logical px)
- **Typography**: Bold fonts, large text for visibility
- **Icons**: System icons + custom shapes (can be replaced with SVGs)

## Device Specification

```
Display:        5" / 800×480 px, landscape or portrait
Touch:          Resistive (SPI)
Interface:      HDMI (video), SPI (touch)
Backend:        Linux
Target App:     Flutter (Dart)
Language:       English only
Scaling:        Responsive via MediaQuery (no hard-coded sizes)
```

## Quick Start

### 1. Run the Prototype

```bash
flutter run -d linux
```

Or on Android/embedded device:

```bash
flutter build apk --release
```

Then install and run on the target 5" device.

### 2. Navigate Demo Screens

The app launches to a **Demo Home Screen** that lists all prototype screens:
- Tap "1. Login" → test the login flow
- Tap "2. Menu" → browse the icon grid
- Tap "3. Tubing Selection" → select tube type/size
- Tap "4. Sealing Process" → run a mock sealing cycle (Press Play to start)
- Tap "5. Settings" → adjust date/time and language

### 3. Change Display Config

Edit `lib/core/config/display_config.dart`:

```dart
const DisplayConfig displayConfig = DisplayConfig(
  widthPx: 800,           // Physical resolution width
  heightPx: 480,          // Physical resolution height
  diagonalInches: 5.0,    // Display diagonal
  minTouchDp: 64.0,       // Min touch target (dp)
  baselineWidth: 360.0,   // Design baseline
  baselineHeight: 640.0,  // Design baseline
  accentColor: Color(0xFFCCCCCC), // Accent color (light gray)
  bgDark: Color(0xFF111111),      // Background (near-black)
  textLight: Color(0xFFFFFFFF),   // Text (white)
  borderDark: Color(0xFF666666),  // Borders (gray)
);
```

Then **rebuild** (`flutter run`) to apply changes across all screens.

## File Structure

```
lib/
├── core/
│   ├── config/
│   │   └── display_config.dart     ← EDIT THIS to change UI scale
│   ├── models/
│   │   └── sealing_models.dart     (phase, log models)
│   └── services/
│       ├── responsive_service.dart (scaling logic)
│       └── mock_machine.dart       (simulated hardware)
├── features/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── menu_screen.dart
│   ├── run/
│   │   └── tubing_selection_screen.dart
│   ├── sealed_process/
│   │   └── sealing_process_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   └── demo/
│       └── demo_home_screen.dart   (entry point for testing)
└── widget/
    └── components/
        └── ui_components.dart       (reusable widgets)
```

## How Responsive Scaling Works

1. **Define baseline** in `display_config.dart` (design resolution, e.g., 360×640)
2. **Compute scale** = min(actual width / baseline width, actual height / baseline height)
3. **Apply scale** to all sizes via `responsive.scaled(baseSize)`:
   ```dart
   final responsive = Responsive(displayConfig, MediaQuery.of(context).size);
   SizedBox(
     width: responsive.touchTargetDp(),    // Min 64 dp for touch
     height: responsive.scaled(56),        // Scales with screen
     child: ...
   )
   ```
4. **Rebuild** to apply changes everywhere

### Example: Change Touch Target Size

```dart
// In display_config.dart
minTouchDp: 56.0,  // Was 64, now 56
```

Rebuild → all buttons become slightly smaller, maintaining proportions.

### Example: Support Different Resolution

```dart
// In display_config.dart (e.g., for a 7" / 1024×600 device)
const DisplayConfig displayConfig = DisplayConfig(
  widthPx: 1024,
  heightPx: 600,
  diagonalInches: 7.0,
  minTouchDp: 64.0,
  baselineWidth: 360.0,
  baselineHeight: 640.0,
  // ... other fields
);
```

Rebuild → UI scales up to fill the larger screen while keeping the same proportions and touch sizes.

## Component Usage Examples

### HeaderBar (Timestamp + Title + Username)

```dart
HeaderBar(
  timestamp: '20.05.2019 11:22:01',
  title: 'Sealing process',
  username: 'Supervis',
  r: responsive,
),
```

### ProgressPhase (Progress Bar with Label)

```dart
ProgressPhase(
  label: 'Heating phase',
  progress: 0.65,  // 0.0 to 1.0
  timeRemaining: '15s',
  r: responsive,
),
```

### ActionBar (OK / Cancel)

```dart
ActionBar(
  r: responsive,
  onOk: () => print('OK pressed'),
  onCancel: () => Navigator.pop(context),
),
```

### IconGrid (Menu)

```dart
final items = [
  IconGridItem(icon: Icons.settings, label: 'Settings'),
  IconGridItem(icon: Icons.storage, label: 'Log data'),
  // ... more items
];

IconGrid(
  items: items,
  r: responsive,
  onItemTap: (index) => print('Tapped item $index'),
),
```

### SpinBox (Dropdown Selector)

```dart
SpinBox(
  label: 'Select tubing type',
  options: ['TuFlux TPE', 'Silicone', 'PVC'],
  initialIndex: 0,
  onChanged: (index) => setState(() => _selected = index),
  r: responsive,
),
```

## Sealing Process Mock Flow

The **MockMachine** simulates a complete sealing cycle:

1. **Idle** → Ready (awaiting start)
2. **Compression phase** → 3 seconds (demo)
3. **Heating phase** → 4 seconds (demo)
4. **Cooling phase** → 5 seconds (demo)
5. **Complete** → Show log

Press **Play** to start; press **Stop** to abort.

### Customize Timings

Edit `lib/core/services/mock_machine.dart`:

```dart
int _getPhaseDuration(SealingPhase phase) {
  switch (phase) {
    case SealingPhase.compression:
      return 3000;  // 3 seconds — change to real duration
    case SealingPhase.heating:
      return 4000;  // 4 seconds
    case SealingPhase.cooling:
      return 5000;  // 5 seconds
    default:
      return 1000;
  }
}
```

## Future Integration

### Hardware Adapter Pattern

To connect real hardware (serial/Modbus/REST), create an adapter:

```dart
// lib/core/services/serial_machine.dart
class SerialMachine implements MachineHal {
  @override
  Stream<PhaseUpdate> get onPhaseUpdate => _controller.stream;

  @override
  Future<void> startProcess() async {
    // Send command to hardware via serial port
    await _serial.write('START\n');
    // Listen for phase updates and emit to stream
  }
}
```

Then swap `MockMachine` for `SerialMachine` in the sealing process screen.

### Add Real Log Storage

Extend `SealingLog` to save to SD card:

```dart
// In sealing_process_screen.dart, on complete:
final log = SealingLog(...);
await _sdCardService.saveLog(log);  // emit event for UI
```

## Testing Checklist

- [ ] Run on 5" / 800×480 device
- [ ] Verify touch target sizes >= 64 dp (no glove fumbling)
- [ ] Check text legibility (high contrast, large fonts)
- [ ] Test orientation changes (use `ScreenRotationService`)
- [ ] Simulate gloved input (larger targets, slower taps)
- [ ] Confirm all transitions (Login → Menu → Tubing → Sealing)
- [ ] Verify scalability: change `display_config.dart` & rebuild

## Notes

- **No hardcoded sizes**: All dimensions use `responsive.scaled()` or `responsive.touchTargetDp()`.
- **Single config file**: One place to control UI scale for all devices.
- **Resistive touch**: Large buttons (56–72 dp), no hover effects, no long-press for critical actions.
- **Responsive layout**: Uses Flutter's `Expanded`, `Flex`, `Row`/`Column`, and `MediaQuery` — scales correctly on any screen.
- **Dark theme only** (as per screenshots). Light theme easy to add if needed.

## Support & Next Steps

1. **Add real hardware driver**: Create a MachineHal adapter for your serial/Modbus protocol.
2. **Expand log storage**: Wire SD card export and log viewer.
3. **Add localization**: Extend strings to support multiple languages.
4. **Performance tuning**: Profile on target device; optimize animations if needed.
5. **Branding**: Replace system icons with custom branded assets (SVG or PNG).

---

**Author**: Prototype built for resistive-touch tube sealer  
**Date**: 2026-03-31  
**Platform**: Flutter (Dart) on Linux
