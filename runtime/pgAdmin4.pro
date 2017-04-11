VERSION = 1.4.0.0
QMAKE_TARGET_COMPANY = "The pgAdmin Development Team"
QMAKE_TARGET_PRODUCT = "pgAdmin 4"
QMAKE_TARGET_DESCRIPTION = "pgAdmin 4 Desktop Runtime"
QMAKE_TARGET_COPYRIGHT = "Copyright 2013 - 2017, The pgAdmin Development Team"

# Configure QT modules for the appropriate version of QT
greaterThan(QT_MAJOR_VERSION, 4) {
    message(Building for QT5+...)

    # Users can force the use of WebKit in Qt5, e.g. qmake "DEFINES += PGADMIN4_USE_WEBKIT"
    contains(DEFINES, PGADMIN4_USE_WEBKIT) {
        message(Forcing use of QWebKit...)
        message()
        message(************************************** WARNING **************************************)
        message(* It is strongly advised that Qt 5.5.0 or later is used to build the pgAdmin runtime.)
        message(*************************************************************************************)
        message()
        QT += webkitwidgets network widgets
    } else {
        greaterThan(QT_MINOR_VERSION, 4) {
            message(Using QWebEngine...)
            DEFINES += PGADMIN4_USE_WEBENGINE
            QT += webenginewidgets network widgets
        } else {
            message(Using QWebKit...)
            message()
            message(************************************** WARNING **************************************)
            message(* It is strongly advised that Qt 5.5.0 or later is used to build the pgAdmin runtime.)
            message(*************************************************************************************)
            message()
            DEFINES *= PGADMIN4_USE_WEBKIT
            QT += webkitwidgets network widgets
        }
    }
} else { 
    message(Building for QT4...)
    message(Using QWebKit...)
    message()
    message(************************************** WARNING **************************************)
    message(* It is strongly advised that Qt 5.5.0 or later is used to build the pgAdmin runtime.)
    message(*************************************************************************************)
    message()
    DEFINES += PGADMIN4_USE_WEBKIT
    QT += webkit network
}
win32 {
  RC_ICONS += pgAdmin4.ico
}

CONFIG(debug, debug|release) {
  DEFINES += PGADMIN4_DEBUG
  message(Configure pgAdmin4 to run in debug mode...)
}

# Environment settings for the build
QMAKE_CFLAGS += $$(PGADMIN_CFLAGS)
QMAKE_CXXFLAGS += $$(PGADMIN_CXXFLAGS)
QMAKE_LFLAGS += $$(PGADMIN_LDFLAGS)

win32 {
    message(Building for Windows...)

    # Read the PYTHON_HOME and PYTHON_VERSION system environment variables.
    PY_HOME = $$(PYTHON_HOME)
    PY_VERSION = $$(PYTHON_VERSION)

    isEmpty(PY_HOME) {
        error(Please define the PYTHON_HOME variable in the system environment.)
    }
    else {
        isEmpty(PY_VERSION) {
            error(Please define the PYTHON_VERSION variable in the system environment.)
        }
        else {
            INCLUDEPATH = $$PY_HOME\include
            LIBS += -L"$$PY_HOME\libs" -lpython$$PY_VERSION

            # Set the PYTHON2 macro if appropriate
            PY2_VERSION = $$find(PY_VERSION, "^2")
            count( PY2_VERSION, 1) {
                message(Python version 2.x detected.)
                DEFINES += PYTHON2
            }
        }
    }
}
else {
    message(Building for Linux/Mac...)

    # Find and configure Python
    # Environment setting
    PYTHON_CONFIG = $$(PYTHON_CONFIG)

    # Python 2?
    isEmpty(PYTHON_CONFIG) {
        PYTHON_CONFIG = $$system(which python-config)
    }

    # Maybe Python 3?
    isEmpty(PYTHON_CONFIG) {
        PYTHON_CONFIG = $$system(which python3-config)
    }

    # Argh!
    isEmpty(PYTHON_CONFIG) {
        error(The python-config executable could not be found. Ensure Python is installed and in the system path.)
    }

    message(Using $$PYTHON_CONFIG)

    QMAKE_CXXFLAGS += $$system($$PYTHON_CONFIG --includes)
    QMAKE_LFLAGS += $$system($$PYTHON_CONFIG --ldflags)
    LIBS += $$system($$PYTHON_CONFIG --libs)

    contains( LIBS, -lpython2.* ) {
       DEFINES += PYTHON2
       message(Python2 detected.)
    } else {
       message(Python3 detected.)
    }
}

# Source code
HEADERS     =   BrowserWindow.h \
                Server.h \
                pgAdmin4.h \
                TabWindow.h \
                WebViewWindow.h \
                ConfigWindow.h
SOURCES     =   pgAdmin4.cpp \
                BrowserWindow.cpp \
                Server.cpp \
                TabWindow.cpp \
                WebViewWindow.cpp \
                ConfigWindow.cpp
FORMS       =   BrowserWindow.ui \
                ConfigWindow.ui
ICON        =   pgAdmin4.icns
QMAKE_INFO_PLIST = Info.plist

RESOURCES += \
    pgadmin4.qrc

