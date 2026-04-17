# Nyctophi Games - Data Core Presentation (Sketch-Blox)

## Overview
This project is an interactive environment built in **Roblox Studio** using **React (Roact)**. Its main purpose is to act as a cinematic stage and control panel to record an educational video (TikTok format) about implementing a **Distributed Database Maintenance Plan** for the fictional game company **Nyctophi Games**.

## Academic Context
* **Course:** Advanced Databases
* **Evidence:** EC1 - Database Management
* **Development Team (Nyctophi Games DBAs):**
    * Joshua Mendez Castillo
    * Maria Isabel Rojas Pastor
    * Jose Francisco Martinez Jacobo
* **Goal:** Explain the replication model, storage strategy, access control, and backup scheduling in a creative way in under 60 seconds.

## Technical Features
* **UI Control Interface (React):** Interactive, modern, and scalable side panel to manage scene animations, cameras, and effects while recording.
* **Dynamic Theming:** The interface color palette automatically adapts to each team member identity based on their Roblox `UserId` (Pink, Blue, or Black).
* **Recording Mode (Overlay):** Keyboard shortcut system designed to clear intrusive UI elements and capture clean cinematic shots.

## Interface Controls
* `[ R ]` - Show or hide the side control menu with smooth transitions.
* `[ H ]` - **Cinematic Mode / Clean Screen:** Hides all UI (including the React menu and Roblox native CoreGui) to record 3D action without distractions.

## Technologies Used
* Roblox Studio (Luau)
* React for Roblox (Roact)
* TweenService (Smooth animations)
* UserInputService (Keyboard shortcut handling)