#!/usr/bin/python

from cursesmenu import *
from cursesmenu.items import *

import boto3

menu = CursesMenu("AWS Manager", "Main Menu")
menu_item = MenuItem("Menu Item")
#function_item = FunctionItem("Call a Python function", input, ["Enter an input"])
#command_item = CommandItem("Run a console command",  "touch hello.txt")
selection_menu = SelectionMenu(["item1", "item2", "item3"])
submenu_item = SubmenuItem("Submenu item", selection_menu, menu)
menu.append_item(menu_item)
menu.append_item(submenu_item)

menu.show()