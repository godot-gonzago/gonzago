@tool
class_name GonzagoApp
extends Node


## Main entry point of the application.


# MainAppStatess:
# - Transitional
# - Splash? Initialization?
# - MainMenu
#   - StartScreen? Input detection
#   - Submenus (Main, Load, Settings, etc.)
# - Gameplay
#   - Levels (Gameplay, GameplayMenus)
#   - PauseMenu (not while GameplayMenu?)
#     - Submenus (Load, Settings)
# - Credits (auto-transition back to MainMenu)
#
# AppStatesGraph
# +--------------+
# |  BootSplash  | Initialize
# +--------------+
# +--------------+
# | StartScreen  | Input gathering
# +--------------+
# +--------------++--------------+
# |   MainMenu   ||  SubMenu     | No transitions horizontally? Live in same scene
# +--------------++--------------+
# +--------------+
# |GameplayState |
# +--------------+
#      +--------------++-------------++--------------+
#      | Level01      ||  Level02    || GameplayMenu | Loading Ssreen On Level Load
#      +--------------++-------------++--------------+
#      +--------------++--------------++--------------+
#      |  PauseMenu   ||   SubMenu    ||   SubMenu    |
#      +--------------++--------------++--------------+
# +--------------+
# |   Credits    |
# +--------------+
