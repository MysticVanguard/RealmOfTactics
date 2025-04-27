# Realm of Tactics

A Flutter implementation of an autochess mobile game with roguelike aspects.

## Overview

Realm of Tactics is a mobile and desktop game where players collect units, place them on a game board, and watch them battle against opponents. Key features include:

- Unit placement and management
- Unit shop system with different tiers and costs
- Class and Origin synergies
- Combat simulation
- Gold management and player leveling

## Project Structure

- **lib/models/**: Data models and game logic
  - `unit.dart`: Base unit class
  - `board_manager.dart`: Game board and unit placement logic
  - `game_manager.dart`: Game state and player stat management
  - `shop_manager.dart`: Shop mechanics and unit purchasing
  - `synergy_manager.dart`: Class/Origin synergy implementation

- **lib/screens/**: UI screens
  - `game_screen.dart`: Main game screen

- **lib/widgets/**: Reusable UI components
  - `game_board.dart`: Game board visualization
  - `unit_widget.dart`: Unit representation
  - `shop_widget.dart`: Shop interface
  - `synergy_display.dart`: Synergy information display

## Running the Project

1. Ensure Flutter is installed and set up
2. Run `flutter pub get` to install dependencies
3. Execute `flutter run` to start the application

## Future Improvements

- Current plans can be found in plans.txt
