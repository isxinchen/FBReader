/*
 * FBReader -- electronic book reader
 * Copyright (C) 2005 Nikolay Pultsin <geometer@mawhrin.net>
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
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include "CollectionView.h"
#include "FBReader.h"

#include "../model/TextModel.h"
#include "../model/Paragraph.h"

#include "../textview/ParagraphCursor.h"

#include "../collection/BookCollection.h"
#include "../description/BookDescription.h"
#include "../description/Author.h"

CollectionView::CollectionView(FBReader &reader, PaintContext &context) : TextView(context), myReader(reader) {
	myCollection = 0;
	myTreeModel = 0;
	myTreeStateIsFrozen = false;
}

CollectionView::~CollectionView() {
	if (myCollection != 0) {
		delete myCollection;
		delete myTreeModel;
	}
}

void CollectionView::gotoParagraph(int num, bool last) {
	if ((num >= 0) && (num < (int)myTreeModel->paragraphs().size())) {
		TreeParagraph *tp = (TreeParagraph*)myTreeModel->paragraphs()[num];
		if (myTreeStateIsFrozen) {
			TreeParagraph *parent = tp->parent();
			while ((num > 0) && (parent != 0) && !parent->isOpen()) {
				for (num--; ((num > 0) && parent != myTreeModel->paragraphs()[num]); num--);
				parent = parent->parent();
			}
		} else {
			tp->openTree();
		}
	}
	
	TextView::gotoParagraph(num, last);
}

void CollectionView::paint() {
	if (!myCollection->isActual()) {
		fill();
	}
	TextView::paint();
}

void CollectionView::fill() {
	if (myCollection != 0) {
		delete myCollection;
		delete myTreeModel;
	}
	myCollection = new BookCollection();
	myTreeModel = new TreeModel();
	const std::vector<const Author*> &authors = myCollection->authors();
	for (std::vector<const Author*>::const_iterator it = authors.begin(); it != authors.end(); it++) {
		TreeParagraph *authorParagraph = myTreeModel->createParagraph();
		authorParagraph->addControl(LIBRARY_AUTHOR_ENTRY, true);
		authorParagraph->addText((*it)->displayName());
		const std::vector<BookDescription*> &books = myCollection->books(*it);
		for (std::vector<BookDescription*>::const_iterator jt = books.begin(); jt != books.end(); jt++) {
			TreeParagraph *bookParagraph = myTreeModel->createParagraph(authorParagraph);
			bookParagraph->addControl(LIBRARY_BOOK_ENTRY, true);
			bookParagraph->addText((*jt)->title());
			myBooksMap[bookParagraph] = *jt;
		}
	}
	setModel(myTreeModel, "Library");
}

bool CollectionView::onStylusPress(int x, int y) {
	myTreeStateIsFrozen = true;
	if (TextView::onStylusPress(x, y)) {
		myTreeStateIsFrozen = false;
		return true;
	}
	myTreeStateIsFrozen = false;

	const ParagraphPosition *position = paragraphByCoordinate(y);
	if (position == 0) {
		return false;
	}

	int paragraphNumber = position->ParagraphNumber;
	if ((paragraphNumber < 0) || ((int)myModel->paragraphs().size() <= paragraphNumber)) {
		return false;
	}

	TreeParagraph *paragraph = (TreeParagraph*)myModel->paragraphs()[paragraphNumber];
	if (!paragraph->children().empty()) {
		const TextElementPosition *elementPosition = elementByCoordinates(x, y);
		if ((elementPosition == 0) || (elementPosition->Kind != TextElement::TREE_ELEMENT)) {
			return false;
		}

		paragraph->open(!paragraph->isOpen());
		repaintView();
		if (paragraph->isOpen()) {
			// TODO: correct next paragraph number calculation for multi-level trees
			int nextParagraphNumber = paragraphNumber + paragraph->children().size() + 1;
			int lastParagraphNumber = myLastParagraphCursor->paragraphNumber();
			if (myLastParagraphCursor->isEndOfParagraph()) {
				lastParagraphNumber++;
			}
			if (lastParagraphNumber < nextParagraphNumber) {
				gotoParagraph(nextParagraphNumber, true);
				repaintView();
			}
		}
		int firstParagraphNumber = myFirstParagraphCursor->paragraphNumber();
		if (myFirstParagraphCursor->isStartOfParagraph()) {
			firstParagraphNumber--;
		}
		if (firstParagraphNumber >= paragraphNumber) {
			gotoParagraph(paragraphNumber);
			repaintView();
		}
	} else {
		std::map<TreeParagraph*,BookDescription*>::const_iterator it = myBooksMap.find(paragraph);
		if (it != myBooksMap.end()) {
			myReader.openBook(new BookDescription(*it->second));
			myReader.showBookTextView();
		}
	}
	return true;
}
