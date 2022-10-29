/*!
 * TOAST UI Editor : i18n
 * @version 3.2.1
 * @author NHN Cloud FE Development Lab <dl_javascript@nhn.com>
 * @license MIT
 */
(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("@toast-ui/editor"));
	else if(typeof define === 'function' && define.amd)
		define(["@toast-ui/editor"], factory);
	else {
		var a = typeof exports === 'object' ? factory(require("@toast-ui/editor")) : factory(root["toastui"]["Editor"]);
		for(var i in a) (typeof exports === 'object' ? exports : root)[i] = a[i];
	}
})(self, function(__WEBPACK_EXTERNAL_MODULE__213__) {
return /******/ (function() { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ 213:
/***/ (function(module) {

module.exports = __WEBPACK_EXTERNAL_MODULE__213__;

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId](module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	!function() {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = function(module) {
/******/ 			var getter = module && module.__esModule ?
/******/ 				function() { return module['default']; } :
/******/ 				function() { return module; };
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	}();
/******/ 	
/******/ 	/* webpack/runtime/define property getters */
/******/ 	!function() {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = function(exports, definition) {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	}();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	!function() {
/******/ 		__webpack_require__.o = function(obj, prop) { return Object.prototype.hasOwnProperty.call(obj, prop); }
/******/ 	}();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	!function() {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = function(exports) {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	}();
/******/ 	
/************************************************************************/
var __webpack_exports__ = {};
// This entry need to be wrapped in an IIFE because it need to be isolated against other modules in the chunk.
!function() {
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _editorCore__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(213);
/* harmony import */ var _editorCore__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_editorCore__WEBPACK_IMPORTED_MODULE_0__);
/**
 * @fileoverview I18N for Polish
 * @author Marcin MikoÅ‚ajczak <me@m4sk.in>
 */

_editorCore__WEBPACK_IMPORTED_MODULE_0___default().setLanguage(['pl', 'pl-PL'], {
    Markdown: 'Markdown',
    WYSIWYG: 'WYSIWYG',
    Write: 'Napisz',
    Preview: 'PodglÄ…d',
    Headings: 'NagÅ‚Ã³wki',
    Paragraph: 'Akapit',
    Bold: 'Pogrubienie',
    Italic: 'Kursywa',
    Strike: 'PrzekreÅ›lenie',
    Code: 'Fragment kodu',
    Line: 'Linia',
    Blockquote: 'Cytat',
    'Unordered list': 'Lista nieuporzÄ…dkowana',
    'Ordered list': 'Lista uporzÄ…dkowana',
    Task: 'Zadanie',
    Indent: 'UtwÃ³rz wciÄ™cie',
    Outdent: 'UsuÅ„ wciÄ™cie',
    'Insert link': 'UmieÅ›Ä‡ odnoÅ›nik',
    'Insert CodeBlock': 'UmieÅ›Ä‡ blok kodu',
    'Insert table': 'UmieÅ›Ä‡ tabelÄ™',
    'Insert image': 'UmieÅ›Ä‡ obraz',
    Heading: 'NagÅ‚Ã³wek',
    'Image URL': 'Adres URL obrazu',
    'Select image file': 'Wybierz plik obrazu',
    'Choose a file': 'Wybierz plik',
    'No file': 'Brak plik',
    Description: 'Opis',
    OK: 'OK',
    More: 'WiÄ™cej',
    Cancel: 'Anuluj',
    File: 'Plik',
    URL: 'URL',
    'Link text': 'Tekst odnoÅ›nika',
    'Add row to up': 'Dodaj wiersz do gÃ³ry',
    'Add row to down': 'Dodaj wiersz w dÃ³Å‚',
    'Add column to left': 'Dodaj kolumnÄ™ po lewej stronie',
    'Add column to right': 'Dodaj kolumnÄ™ po prawej stronie',
    'Remove row': 'UsuÅ„ rzÄ…d',
    'Remove column': 'UsuÅ„ kolumnÄ™',
    'Align column to left': 'WyrÃ³wnaj do lewej',
    'Align column to center': 'WyÅ›rodkuj',
    'Align column to right': 'WyrÃ³wnaj do prawej',
    'Remove table': 'UsuÅ„ tabelÄ™',
    'Would you like to paste as table?': 'Czy chcesz wkleiÄ‡ tekst jako tabelÄ™?',
    'Text color': 'Kolor tekstu',
    'Auto scroll enabled': 'WÅ‚Ä…czono automatyczne przewijanie',
    'Auto scroll disabled': 'WyÅ‚Ä…czono automatyczne przewijanie',
    'Choose language': 'Wybierz jÄ™zyk',
});

}();
/******/ 	return __webpack_exports__;
/******/ })()
;
});