#!/bin/bash
set -e

echo "🌟 Setting up Digital Notepad with Superpowers..."

PROJECT_DIR="super-notepad"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# --- notepadgui.h ---
cat > notepadgui.h <<'EOF'
#ifndef NOTEPADGUI_H
#define NOTEPADGUI_H

#include <QMainWindow>

class QTextEdit;
class QLabel;

class NotepadGUI : public QMainWindow {
    Q_OBJECT
public:
    explicit NotepadGUI(QWidget *parent = nullptr);
    ~NotepadGUI();

private slots:
    // File actions
    void newFile();
    void openFile();
    bool saveFile();
    bool saveAsFile();
    void maybeSaveAndNew();

    // Edit actions
    void cut();
    void copy();
    void paste();
    void selectAll();

    // Find / Replace
    void findText();
    void replaceText();

    // Other utilities
    void updateStatus();
    void toggleDarkMode();
    void showAbout();

private:
    void createActions();
    void createMenus();
    void createToolBar();
    void createStatusBar();
    bool maybeSave();
    bool writeToFile(const QString &fileName);
    bool readFromFile(const QString &fileName);
    void setCurrentFile(const QString &fileName);
    QString strippedName(const QString &fullFileName);

    QTextEdit *textEdit;
    QString currentFile;
    QLabel *statusLabel;

    // Actions
    QAction *actionNew;
    QAction *actionOpen;
    QAction *actionSave;
    QAction *actionSaveAs;
    QAction *actionExit;

    QAction *actionCut;
    QAction *actionCopy;
    QAction *actionPaste;
    QAction *actionSelectAll;
    QAction *actionUndo;
    QAction *actionRedo;

    QAction *actionFind;
    QAction *actionReplace;
    QAction *actionDarkMode;
    QAction *actionAbout;
};

#endif // NOTEPADGUI_H
EOF

# --- notepadgui.cpp ---
cat > notepadgui.cpp <<'EOF'
#include "notepadgui.h"
#include <QTextEdit>
#include <QMenuBar>
#include <QToolBar>
#include <QFileDialog>
#include <QMessageBox>
#include <QStatusBar>
#include <QLabel>
#include <QAction>
#include <QApplication>
#include <QFile>
#include <QTextStream>
#include <QKeySequence>
#include <QInputDialog>

NotepadGUI::NotepadGUI(QWidget *parent)
    : QMainWindow(parent), textEdit(new QTextEdit(this)), statusLabel(new QLabel(this))
{
    setCentralWidget(textEdit);
    createActions();
    createMenus();
    createToolBar();
    createStatusBar();

    setCurrentFile(QString());
    resize(900, 600);
    setWindowTitle("Digital Notepad – Superpowers");
    connect(textEdit->document(), &QTextDocument::modificationChanged, this, &NotepadGUI::updateStatus);
}

NotepadGUI::~NotepadGUI() {}

void NotepadGUI::createActions()
{
    // File
    actionNew = new QAction("&New", this);
    actionNew->setShortcut(QKeySequence::New);
    connect(actionNew, &QAction::triggered, this, &NotepadGUI::newFile);

    actionOpen = new QAction("&Open...", this);
    actionOpen->setShortcut(QKeySequence::Open);
    connect(actionOpen, &QAction::triggered, this, &NotepadGUI::openFile);

    actionSave = new QAction("&Save", this);
    actionSave->setShortcut(QKeySequence::Save);
    connect(actionSave, &QAction::triggered, this, &NotepadGUI::saveFile);

    actionSaveAs = new QAction("Save &As...", this);
    actionSaveAs->setShortcut(QKeySequence(Qt::CTRL + Qt::SHIFT + Qt::Key_S));
    connect(actionSaveAs, &QAction::triggered, this, &NotepadGUI::saveAsFile);

    actionExit = new QAction("E&xit", this);
    actionExit->setShortcut(QKeySequence::Quit);
    connect(actionExit, &QAction::triggered, qApp, &QApplication::closeAllWindows);

    // Edit
    actionUndo = new QAction("&Undo", this);
    actionUndo->setShortcut(QKeySequence::Undo);
    connect(actionUndo, &QAction::triggered, textEdit, &QTextEdit::undo);

    actionRedo = new QAction("&Redo", this);
    actionRedo->setShortcut(QKeySequence::Redo);
    connect(actionRedo, &QAction::triggered, textEdit, &QTextEdit::redo);

    actionCut = new QAction("Cu&t", this);
    actionCut->setShortcut(QKeySequence::Cut);
    connect(actionCut, &QAction::triggered, this, &NotepadGUI::cut);

    actionCopy = new QAction("&Copy", this);
    actionCopy->setShortcut(QKeySequence::Copy);
    connect(actionCopy, &QAction::triggered, this, &NotepadGUI::copy);

    actionPaste = new QAction("&Paste", this);
    actionPaste->setShortcut(QKeySequence::Paste);
    connect(actionPaste, &QAction::triggered, this, &NotepadGUI::paste);

    actionSelectAll = new QAction("Select &All", this);
    actionSelectAll->setShortcut(QKeySequence::SelectAll);
    connect(actionSelectAll, &QAction::triggered, this, &NotepadGUI::selectAll);

    actionFind = new QAction("&Find...", this);
    actionFind->setShortcut(QKeySequence::Find);
    connect(actionFind, &QAction::triggered, this, &NotepadGUI::findText);

    actionReplace = new QAction("&Replace...", this);
    actionReplace->setShortcut(QKeySequence(Qt::CTRL + Qt::Key_H));
    connect(actionReplace, &QAction::triggered, this, &NotepadGUI::replaceText);

    actionDarkMode = new QAction("&Toggle Dark Mode", this);
    actionDarkMode->setCheckable(true);
    connect(actionDarkMode, &QAction::triggered, this, &NotepadGUI::toggleDarkMode);

    actionAbout = new QAction("&About", this);
    connect(actionAbout, &QAction::triggered, this, &NotepadGUI::showAbout);
}

void NotepadGUI::createMenus()
{
    QMenu *fileMenu = menuBar()->addMenu("&File");
    fileMenu->addAction(actionNew);
    fileMenu->addAction(actionOpen);
    fileMenu->addAction(actionSave);
    fileMenu->addAction(actionSaveAs);
    fileMenu->addSeparator();
    fileMenu->addAction(actionExit);

    QMenu *editMenu = menuBar()->addMenu("&Edit");
    editMenu->addAction(actionUndo);
    editMenu->addAction(actionRedo);
    editMenu->addSeparator();
    editMenu->addAction(actionCut);
    editMenu->addAction(actionCopy);
    editMenu->addAction(actionPaste);
    editMenu->addAction(actionSelectAll);
    editMenu->addSeparator();
    editMenu->addAction(actionFind);
    editMenu->addAction(actionReplace);

    QMenu *viewMenu = menuBar()->addMenu("&View");
    viewMenu->addAction(actionDarkMode);

    QMenu *helpMenu = menuBar()->addMenu("&Help");
    helpMenu->addAction(actionAbout);
}

void NotepadGUI::createToolBar()
{
    QToolBar *tb = addToolBar("Main");
    tb->addAction(actionNew);
    tb->addAction(actionOpen);
    tb->addAction(actionSave);
    tb->addSeparator();
    tb->addAction(actionUndo);
    tb->addAction(actionRedo);
    tb->addSeparator();
    tb->addAction(actionCut);
    tb->addAction(actionCopy);
    tb->addAction(actionPaste);
}

void NotepadGUI::createStatusBar()
{
    statusBar()->addWidget(statusLabel, 1);
    updateStatus();
}

void NotepadGUI::updateStatus()
{
    QString status;
    if (currentFile.isEmpty()) status = "Untitled";
    else status = strippedName(currentFile);

    if (textEdit->document()->isModified()) status += " (modified)";

    statusLabel->setText(status);
}

void NotepadGUI::newFile()
{
    if (!maybeSave()) return;
    textEdit->clear();
    setCurrentFile(QString());
}

void NotepadGUI::openFile()
{
    if (!maybeSave()) return;
    QString fileName = QFileDialog::getOpenFileName(this, "Open File");
    if (!fileName.isEmpty()) {
        if (readFromFile(fileName))
            setCurrentFile(fileName);
    }
}

bool NotepadGUI::saveFile()
{
    if (currentFile.isEmpty()) return saveAsFile();
    return writeToFile(currentFile);
}

bool NotepadGUI::saveAsFile()
{
    QString fileName = QFileDialog::getSaveFileName(this, "Save File As");
    if (fileName.isEmpty()) return false;
    if (writeToFile(fileName)) {
        setCurrentFile(fileName);
        return true;
    }
    return false;
}

void NotepadGUI::maybeSaveAndNew()
{
    if (maybeSave()) {
        newFile();
    }
}

bool NotepadGUI::maybeSave()
{
    if (!textEdit->document()->isModified()) return true;

    QMessageBox::StandardButton ret =
        QMessageBox::warning(this, "Digital Notepad",
                             "The document has been modified.\nDo you want to save your changes?",
                             QMessageBox::Save | QMessageBox::Discard | QMessageBox::Cancel);
    if (ret == QMessageBox::Save) return saveFile();
    if (ret == QMessageBox::Cancel) return false;
    return true; // Discard
}

bool NotepadGUI::writeToFile(const QString &fileName)
{
    QFile file(fileName);
    if (!file.open(QFile::WriteOnly | QFile::Text)) {
        QMessageBox::warning(this, "Digital Notepad",
                             QString("Cannot write file %1:\n%2.").arg(fileName, file.errorString()));
        return false;
    }

    QTextStream out(&file);
    out << textEdit->toPlainText();
    file.close();
    textEdit->document()->setModified(false);
    updateStatus();
    return true;
}

bool NotepadGUI::readFromFile(const QString &fileName)
{
    QFile file(fileName);
    if (!file.open(QFile::ReadOnly | QFile::Text)) {
        QMessageBox::warning(this, "Digital Notepad",
                             QString("Cannot read file %1:\n%2.").arg(fileName, file.errorString()));
        return false;
    }

    QTextStream in(&file);
    textEdit->setPlainText(in.readAll());
    textEdit->document()->setModified(false);
    file.close();
    updateStatus();
    return true;
}

void NotepadGUI::setCurrentFile(const QString &fileName)
{
    currentFile = fileName;
    textEdit->document()->setModified(false);
    updateStatus();
    setWindowTitle(QString("%1 - Digital Notepad").arg(currentFile.isEmpty() ? "Untitled" : strippedName(currentFile)));
}

QString NotepadGUI::strippedName(const QString &fullFileName)
{
    return QFileInfo(fullFileName).fileName();
}

void NotepadGUI::cut() { textEdit->cut(); }
void NotepadGUI::copy() { textEdit->copy(); }
void NotepadGUI::paste() { textEdit->paste(); }
void NotepadGUI::selectAll() { textEdit->selectAll(); }

void NotepadGUI::findText()
{
    bool ok;
    QString text = QInputDialog::getText(this, "Find", "Find:", QLineEdit::Normal, "", &ok);
    if (!ok || text.isEmpty()) return;

    // simple find: move cursor to first match
    QTextDocument *doc = textEdit->document();
    QTextCursor cursor = doc->find(text, 0);
    if (!cursor.isNull()) {
        textEdit->setTextCursor(cursor);
    } else {
        QMessageBox::information(this, "Find", "No matches found.");
    }
}

void NotepadGUI::replaceText()
{
    bool ok;
    QString findStr = QInputDialog::getText(this, "Replace", "Find:", QLineEdit::Normal, "", &ok);
    if (!ok || findStr.isEmpty()) return;
    QString replaceStr = QInputDialog::getText(this, "Replace", "Replace with:", QLineEdit::Normal, "", &ok);
    if (!ok) return;

    // Replace all occurrences in entire document (simple)
    QString content = textEdit->toPlainText();
    int occurrences = 0;
    int pos = 0;
    while ((pos = content.indexOf(findStr, pos, Qt::CaseSensitive)) != -1) {
        content.replace(pos, findStr.length(), replaceStr);
        pos += replaceStr.length();
        occurrences++;
    }

    if (occurrences == 0) {
        QMessageBox::information(this, "Replace", "No matches found.");
    } else {
        textEdit->setPlainText(content);
        QMessageBox::information(this, "Replace", QString("Replaced %1 occurrence(s).").arg(occurrences));
    }
}

void NotepadGUI::toggleDarkMode()
{
    if (actionDarkMode->isChecked()) {
        QString style = "QWidget{ background: #121212; color: #e0e0e0 }"
                        "QTextEdit { background: #1e1e1e; color: #e0e0e0 }"
                        "QMenuBar { background: #151515; color: #e0e0e0 }"
                        "QMenu { background: #151515; color: #e0e0e0 }"
                        "QToolBar { background: #151515; color: #e0e0e0 }";
        qApp->setStyleSheet(style);
    } else {
        qApp->setStyleSheet("");
    }
}

void NotepadGUI::showAbout()
{
    QMessageBox::about(this, "About Digital Notepad",
                       "Digital Notepad with Superpowers\n"
                       "Features: New/Open/Save/Save As, Undo/Redo, Cut/Copy/Paste, Find/Replace, Dark Mode.\n"
                       "Built with Qt.");
}
EOF

# --- main.cpp ---
cat > main.cpp <<'EOF'
#include <QApplication>
#include "notepadgui.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    NotepadGUI w;
    w.show();
    return a.exec();
}
EOF

# --- notepad.pro ---
cat > notepad.pro <<'EOF'
QT += widgets

TARGET = notepad

SOURCES += main.cpp \
           notepadgui.cpp

HEADERS += notepadgui.h
EOF

echo "🧹 Cleaning old build artifacts..."
rm -f Makefile .qmake.stash moc_* *.o notepad

echo "🔨 Running qmake..."
qmake

echo "⚙️ Building..."
make -j$(nproc)

if [ -f notepad ]; then
    echo "✅ Build completed. Launching notepad..."
    ./notepad
else
    echo "❌ Build failed."
    exit 1
fi

