📝 Digital Notepad with Superpowers
A simple yet powerful GUI-based text editor built using C++ and Qt
📌 Overview

Digital Notepad with Superpowers is a lightweight text editor application built using Qt (C++ GUI framework).
It works like a basic version of Notepad, allowing users to create, open, edit, and save text files easily.
The project demonstrates fundamental concepts of GUI development, file handling, and event-driven programming.

This project is ideal for beginners learning GUI programming or students building a project for college submissions.

✨ Features

✔️ Create new text files
✔️ Open existing .txt files
✔️ Save text files
✔️ Clean and minimal GUI
✔️ Fully written in C++
✔️ Uses Qt Widgets
✔️ Smooth text editing with QTextEdit
✔️ Cross-platform support (Linux, Windows, Mac)

🛠 Tech Stack

Language: C++

Framework: Qt (Qt5/Qt6)

GUI Component: QTextEdit

Build System: qmake + make

OS Used: Linux (Works on all OS)

📁 Project Structure
Gui-Notepad/
│── main.cpp
│── notepadgui.h
│── notepadgui.cpp
│── notepad.pro
│── setup_notepad.sh   (auto-build script)
│── README.md

🚀 How to Build & Run
1. Install Qt (if not installed)
sudo apt install qtbase5-dev qt5-qmake build-essential

2. Navigate to project folder
cd Gui-Notepad

3. Generate Makefile using qmake
qmake

4. Build the project
make

5. Run the Notepad app
./notepad

