/*
 * Copyright (C) 2004-2010 Geometer Plus <contact@geometerplus.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
 * 02110-1301, USA.
 */

#if QT5
  #include <QGuiApplication>
  #if SAILFISH
    //#include <sailfishapp/sailfishapp.h>
  #endif
#else
  #include <QApplication>
#endif

#include <QTextCodec>

#include <ZLApplication.h>
#include <ZLibrary.h>
#include <ZLLanguageUtil.h>

#include "../../../../core/src/unix/library/ZLibraryImplementation.h"

#include "../filesystem/ZLQtFSManager.h"
#include "../time/ZLQtTime.h"
#include "../dialogs/ZLQmlDialogManager.h"
#include "../image/ZLQtImageManager.h"
#include "../view/ZLQmlPaintContext.h"
#include "../network/ZLQtNetworkManager.h"
#include "../../unix/message/ZLUnixMessage.h"
#include "../../../../core/src/util/ZLKeyUtil.h"
#include "../../../../core/src/unix/xmlconfig/XMLConfig.h"
#include "../../../../core/src/unix/iconv/IConvEncodingConverter.h"
//#include "../../../../core/src/unix/curl/ZLCurlNetworkManager.h"

class ZLQmlLibraryImplementation : public ZLibraryImplementation {

private:
	void init(int &argc, char **&argv);
	ZLPaintContext *createContext();
	void run(ZLApplication *application);
};

void initLibrary() {
	new ZLQmlLibraryImplementation();
}

void ZLQmlLibraryImplementation::init(int &argc, char **&argv) {
#if SAILFISH
    //SailfishApp::application(argc, argv);
    new QGuiApplication(argc, argv);
#elif QT5
    new QGuiApplication(argc, argv);
#else
    new QApplication(argc, argv);
#endif

	ZLibrary::parseArguments(argc, argv);

	XMLConfigManager::createInstance();
	ZLQtTimeManager::createInstance();
	ZLQtFSManager::createInstance();
	ZLQmlDialogManager::createInstance();
	ZLUnixCommunicationManager::createInstance();
	ZLQtImageManager::createInstance();
	ZLEncodingCollection::Instance().registerProvider(new IConvEncodingConverterProvider());
	ZLQtNetworkManager::createInstance();
}

ZLPaintContext *ZLQmlLibraryImplementation::createContext() {
	return new ZLQmlPaintContext();
}

void ZLQmlLibraryImplementation::run(ZLApplication *application) {
	if (ZLLanguageUtil::isRTLLanguage(ZLibrary::Language())) {
		qApp->setLayoutDirection(Qt::RightToLeft);
	}
	static_cast<ZLQtNetworkManager&>(ZLNetworkManager::Instance()).initPaths();
	ZLDialogManager::Instance().createApplicationWindow(application);
	application->initWindow();
	qDebug("%s %d", Q_FUNC_INFO, __LINE__);
	qApp->exec();
	qDebug("%s %d", Q_FUNC_INFO, __LINE__);
	delete application;
	qDebug("%s %d", Q_FUNC_INFO, __LINE__);
}
