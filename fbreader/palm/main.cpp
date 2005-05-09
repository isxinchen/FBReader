#include <zlib.h>

#include <palm/PalmOptions.h>
#include <palm/ZLPalmTime.h>
#include <palm/ZLPalmFSManager.h>
#include <palm/PalmDialogManager.h>
#include <palm/PalmScreenSize.h>

#include "PalmFBReader.h"
#include "PalmFBReader-resources.h"

#include <vector>
#include <string>

PalmFBReader *READER;

UInt32 PilotMain(UInt16 cmd, MemPtr /*cmdPBP*/, UInt16 /*launchFlags*/) {
	if (cmd == sysAppLaunchCmdNormalLaunch) {
		ZLSetup;
		ZLPalmTimeManager::createInstance();
		ZLPalmFSManager::createInstance();
		PalmOptions::createInstance("FBReader");
		PalmDialogManager::createInstance();
		PalmScreenSize::createInstance();

		READER = new PalmFBReader();
		FrmGotoForm(MainFBReaderForm);
		EventLoop();
		delete READER;

		PalmScreenSize::deleteInstance();
		PalmDialogManager::deleteInstance();
		PalmOptions::deleteInstance();
		ZLPalmFSManager::deleteInstance();
		ZLPalmTimeManager::deleteInstance();
		ZLTeardown;

		FrmSaveAllForms();
		FrmCloseAllForms();
	}

	return 0;
}
