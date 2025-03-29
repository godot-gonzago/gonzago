@tool
class_name GonzagoApp
extends Node
## Main entry point of a Gonzago application.
##
## TODO: Document according to
##       https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html

# - ApplicationDomain
#   - Initialization
#       (Systems get booted up)
#     - Splash, Intro etc.
#   - ConfigurationDomain
#       (Sets context for gameplay like loading or matchmaking etc.)
#       (App config = input, display settings. etc.)
#       (Can exit completely)
#     - StartScreen, Menu etc.
#   - GameplayDomain (Based on config)
#     - Gameplay
#       (Can block context change? eg. GameplayMenus like craftig, might pause or might not)
#     - Pause
#       (Can set context for gameplay like loading)
#       (App config = input, display settings. etc.)
#       (Can exit back to ConfigurationDomain or exit completely
#   - Cleanup
#       (Systems get shut down)
#
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
