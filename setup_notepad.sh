#!/bin/bash

echo "📦 Creating Qt Digital Notepad Project..."

mkdir -p gui-notepad
cd gui-notepad

###############################
# Create notepadgui.h
###############################
cat << 'EOF' > notepadgui.h
#ifndef NOTEPADGUI_H
#define NOTEPADGUI_H

#include <QWidget>
#include <QTextEdit>
#include <QVBoxLayout>

class NotepadGUI : public QWidget {
    Q_OBJECT
public:
    explicit NotepadGUI(QWidget *parent = nullptr);

private:
    QTextEdit *textArea;
};

#endif // NOTEPADGUI_H
EOF

###############################
# Create notepadgui.cpp
###############################
cat << 'EOF' > notepadgui.cpp
#include "notepadgui.h"

NotepadGUI::NotepadGUI(QWidget *parent)
    : QWidget(parent)
{
    textArea = new QTextEdit(this);

    QVBoxLayout *layout = new QVBoxLayout(this);
    layout->addWidget(textArea);

    setLayout(layout);
    setWindowTitle("Digital Notepad (Qt)");
    resize(600, 400);
}
EOF

###############################
# Create main.cpp
###############################
cat << 'EOF' > main.cpp
#include <QApplication>
#include "notepadgui.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    NotepadGUI window;
    window.show();

    return app.exec();
}
EOF

###############################
# Create Qt project file
###############################
cat << 'EOF' > notepad.pro
QT += widgets

SOURCES += main.cpp \
           notepadgui.cpp

HEADERS += notepadgui.h
EOF

echo "🔨 Running qmake..."
rm -f Makefile .qmake.stash moc_*
qmake

echo "⚙️ Building project..."
make -j4

if [ -f notepad ]; then
    echo "🚀 Launching Notepad..."
    ./notepad
else
    echo "❌ Build failed."
fi

