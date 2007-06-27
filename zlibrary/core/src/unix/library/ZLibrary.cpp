/*
 * Copyright (C) 2004-2007 Nikolay Pultsin <geometer@mawhrin.net>
 * Copyright (C) 2005 Mikhail Sobolev <mss@mawhrin.net>
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

#include <locale.h>
#include <dlfcn.h>

#include <algorithm>

#include <ZLibrary.h>

#include "ZLibraryImplementation.h"

const std::string ZLibrary::FileNameDelimiter("/");
const std::string ZLibrary::PathDelimiter(":");
const std::string ZLibrary::EndOfLine("\n");

std::string ZLibrary::Language() {
	if (!ourLanguage.empty()) {
		return ourLanguage;
	}

	const char *locale = setlocale(LC_MESSAGES, ""); 
	if (locale != 0) {
		std::string lang = locale;
		int index = std::min(lang.find('.'), std::min(lang.find('_'), lang.find('-')));
		if (index != -1) {
			lang = lang.substr(0, index);
		}
		if (!lang.empty()) {
			return lang;
		}
	}
	return "en";
}

ZLibraryImplementation *ZLibraryImplementation::Instance = 0;

ZLibraryImplementation::ZLibraryImplementation() {
	Instance = this;
}

ZLibraryImplementation::~ZLibraryImplementation() {
}

bool ZLibrary::init(int &argc, char **&argv) {
	std::string pluginPath = std::string(INSTALLDIR) + "/share/zlibrary/ui/";
	void *handle = dlopen((pluginPath + "zlui-gtk.so").c_str(), RTLD_NOW);
	if (handle == 0) {
		return false;
	}
	dlerror();

	void (*initLibrary)();
	*(void**)&initLibrary = dlsym(handle, "initLibrary");
	if (dlerror() != 0) {
		return false;
	}
	initLibrary();

	if (ZLibraryImplementation::Instance == 0) {
		return false;
	}

	ZLibraryImplementation::Instance->init(argc, argv);
	return true;
}

ZLPaintContext *ZLibrary::createContext() {
	return ZLibraryImplementation::Instance->createContext();
}

void ZLibrary::run(ZLApplication *application) {
	ZLibraryImplementation::Instance->run(application);
}