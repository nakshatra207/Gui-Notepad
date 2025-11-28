#!/bin/bash

# Fix Qt Notepad Project Automatically

echo "🔧 Fixing Qt project..."

# Remove wrong MOC include line from main.cpp
sed -i '/moc_gui_notepad.cpp/d' main.cpp

# Remove old Makefiles
rm -f Makefile .qmake.stash *.o moc_*

# Rebuild using qmake + make
echo "🔨 Running qmake..."
qmake

echo "⚙️ Building project..."
make -j4

# Run if build successful
if [ -f gui-notepad ]; then
    echo "🚀 Running GUI Notepad..."
    ./gui-notepad
else
    echo "❌ Build failed."
fi

