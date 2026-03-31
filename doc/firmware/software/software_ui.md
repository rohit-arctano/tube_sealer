sequenceDiagram
    autonumber

    actor User
    participant UI as Flutter UI
    participant Nav as Navigation / Route Guard
    participant Auth as Auth Controller
    participant Role as Role Manager
    participant Recipe as Recipe Controller
    participant Process as Process Controller
    participant State as App State / State Manager
    participant Native as Native Bridge / FFI
    participant DB as Local Storage / Local DB

    User->>UI: Open application
    UI->>Nav: Load initial route
    Nav->>UI: Show login screen

    User->>UI: Enter username and password
    UI->>Auth: Login request
    Auth->>DB: Verify credentials
    DB-->>Auth: User record + role
    Auth->>Role: Store role permissions
    Role-->>State: Update logged-in session
    State-->>UI: Render dashboard by role

    alt Operator login
        UI-->>User: Show process screen, status, read-only maintenance
    else Supervisor login
        UI-->>User: Show process, operator management, export, read-only maintenance
    else Admin login
        UI-->>User: Show full access including settings and maintenance actions
    end

    User->>UI: Open recipe / pipe size / brand screen
    UI->>Recipe: Request predefined combinations
    Recipe->>DB: Read recipe data
    DB-->>Recipe: Recipe list
    Recipe-->>State: Update recipe options
    State-->>UI: Show valid recipe selections

    User->>UI: Select pipe size and brand
    UI->>Recipe: Save selected recipe
    Recipe-->>State: Update active selection
    State-->>UI: Show selected configuration

    User->>UI: Tap Start Cycle
    UI->>Process: startCycle()
    Process->>Role: Check permission
    Role-->>Process: Allowed
    Process->>Native: Send start command

    Native-->>State: Status = Pre-check
    State-->>UI: Show pre-check in progress

    Native-->>State: Status = Heating
    State-->>UI: Show heating phase and progress

    Native-->>State: Status = Actuator engaged
    State-->>UI: Show actuator active

    Native-->>State: Status = Motor running / sealing
    State-->>UI: Show sealing phase and progress

    Native-->>State: Status = Cooling
    State-->>UI: Show cooling phase and progress

    alt Cycle completed
        Native-->>State: Status = Complete
        State-->>UI: Show cycle completion
    else Fault occurred
        Native-->>State: Status = Fault + fault code
        State-->>UI: Show alarm / error message
    end

    opt Maintenance screen
        User->>UI: Open maintenance screen
        UI->>Role: Check maintenance access
        Role-->>UI: Access allowed by role
        UI->>DB: Read maintenance status
        DB-->>UI: Counters and alerts
        UI-->>User: Show maintenance information
    end

    opt Settings screen (Admin only)
        User->>UI: Open settings
        UI->>Role: Check admin permission
        Role-->>UI: Access granted
        UI->>DB: Read system settings
        DB-->>UI: Current settings
        UI-->>User: Show settings page

        User->>UI: Modify settings
        UI->>Role: Re-check admin permission
        Role-->>UI: Allowed
        UI->>DB: Save updated settings
        DB-->>UI: Settings saved
        UI-->>User: Show update success
    end

    opt User management
        User->>UI: Open user management
        UI->>Role: Check permission
        Role-->>UI: Supervisor/Admin allowed
        UI->>DB: Read user list
        DB-->>UI: Users
        UI-->>User: Show user list

        User->>UI: Add / edit / delete user
        UI->>DB: Save user change
        DB-->>UI: Update complete
        UI-->>User: Show result
    end

    opt Export records
        User->>UI: Tap export records
        UI->>Role: Check export permission
        Role-->>UI: Supervisor/Admin allowed
        UI->>DB: Request audit / report data
        DB-->>UI: Export data ready
        UI-->>User: Show export success
    end

    User->>UI: Logout
    UI->>Auth: Clear session
    Auth-->>State: Remove logged-in user
    State-->>Nav: Reset route
    Nav-->>UI: Return to login screen

## Screen-to-file mapping (competitor visuals → project files)

- Login / User select / Numeric keypad: `lib/features/auth/login_screen.dart` (dialog: `_NumericKeyboardDialog`).
- Main Shell (top status + bottom nav): `lib/features/shell/main_shell_screen.dart` (uses `TopStatusBar`, `BottomNavBar`).
- Home / Menu: `lib/features/home/presentation/home_screen.dart`, `lib/features/home/menu_screen.dart`.
- Sealing / Process (phases: pre-check, heating, actuator, sealing, cooling, complete/fault): `lib/features/sealed_process/sealing_process_screen.dart`.
- Run / Tubing selection: `lib/features/run/tubing_selection_screen.dart`, `lib/features/run/presentation/run_screen.dart`.
- Recipe / Pipe size / Brand: `lib/features/recipes/presentation/recipe_screen.dart`.
- History: `lib/features/history/presentation/history_screen.dart`.
- Alarms: `lib/features/alarms/presentation/alarm_screen.dart`.
- Settings (admin): `lib/features/settings/settings_screen.dart` and presentation variant `lib/features/settings/presentation/settings_screen.dart`.
- User management: `lib/features/user_management/presentation/user_management_screen.dart`.
- Export / Reports: `lib/features/export/presentation/export_screen.dart`.
- Maintenance: `lib/features/maintenance/presentation/maintenance_screen.dart`.

Notes:
- The above maps functional screens to implementation files. Visual parity (fonts, exact spacing, iconography, and screenshots from the competitor manual) still requires styling and asset updates in the listed files.
- I updated the numeric keypad dialog and the settings layout in code to improve touch sizing and avoid layout/runtime errors. Apply and test on the target resolution (800×480) and iterate on `lib/core/config/display_config.dart` values for final scaling.