This GitHub repository holds code and data unrelated to specific assignments. See [2. Technical Setup](#2-technical-setup) for standing instructions related to technical setup.

## 1. Contents

```text
ss368-fall-2026/classroom-materials
├── README.md
├── docs/                            Data dictionaries, codebooks, etc.
├── code/
│   ├── 01_lln_clt_demo.do           LLN and CLT visualizations
│   ├── 02_hypothesis_testing.do     t-tests, p-values, confidence intervals
│   └── 03_ci_demo_20_sided_die.do   CI demo with a 20-sided die
├── data/
│   ├── 00_raw/                      Raw datasets — never altered or deleted
│   ├── 10_working/                  Imported and cleaned datasets
│   └── jw_datasets/                 Static datasets from the Wooldridge textbook
└── output/
    ├── logs/
    ├── figures/
    ├── tables/
    └── notebooks/
```

## 2. Technical Setup

This section is a standalone reference for setting up your coding environment — Git, GitHub, and VS Code with Stata. Refer back to it any time during the semester if you need to reinstall or fix something.

### 2A. Prerequisites

1. VS Code installed
2. A GitHub account

### 2B. Install and Configure Git

1. Download the latest version of Git: https://git-scm.com/downloads
   - On "Choosing the default editor used by Git," select **VS Code**.

     ![Git setup - choosing VS Code as default editor](screenshots/git-download-vs-code-default.png)

   - On "Adjusting the name of the initial branch in new repositories," select **Override the default branch name for new repositories** and enter `main`.

     ![Git setup - Override Initial Branch](screenshots/git-download-branch-override.png)

   - Accept the defaults for the rest of the installation.
2. In VS Code, open a terminal (Terminal > New Terminal) and configure your identity so commits are correctly attributed to you. Use the same email address registered with GitHub:
   ```
   git config --global user.name "Your Name"
   git config --global user.email "your-github-email@example.com"
   ```
3. The first time you clone a repo or push changes, VS Code will open a browser window asking you to sign in to GitHub. Sign in once there — VS Code remembers you after that.

### 2C. VS Code Extensions

In the Extensions sidebar icon, install:

1. **Stata Enhanced** — syntax highlighting for Stata code
2. **Markdown Preview Enhanced** — lets you preview `.md` files (like this one) as rendered/PDF output

### 2D. Stata Hotkeys in VS Code

This sets up keyboard shortcuts that send Stata code from a `.do` file in VS Code directly to an open Stata window.

1. Copy the `runstata_vscode` folder to `C:\`. To find your `C` drive, open File Explorer > navigate to `This PC` and double-click on `Windows (C:)`. 
2. In VS Code, open a new PowerShell terminal and run:
   ```powershell
   cd "C:\runstata_vscode"; .\startup.ps1
   ```
3. If you get an execution-policy error, run this once, then retry the command above:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
   This may prompt a Y/N confirmation — type `Y` and press Enter.
   - If that command itself errors out (e.g., a locked-down/managed device), use this fallback instead:
     ```powershell
     cd "C:\runstata_vscode"; powershell -ExecutionPolicy Bypass -File .\startup.ps1
     ```
4. `startup.ps1` installs a shortcut that relaunches the hotkeys at every login (a few minutes' delay is normal), so you only need to do this once per computer.

**Using the hotkeys:** with Stata open and a `.do` file focused in VS Code —

| Keys | Action |
|------|--------|
| `Ctrl+D` / `Ctrl+R` / `Ctrl+I` | `do` / `run` / `include` the **selection** |
| `Ctrl+Shift+D` / `+R` / `+I` | same, for the **whole file** |

With nothing selected, `Ctrl+D` runs the current line. Hotkeys are only active while VS Code is the focused window, and they overwrite VS Code's default keyboard bindings.
