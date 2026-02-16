;;; radb-mode.el --- Major mode for editing radb (relational algebra) files. -*- lexical-binding: t -*-

;; Author: Boris Glavic <lordpretzel@gmail.com>
;; Maintainer: Boris Glavic <lordpretzel@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "29"))
;; Homepage: https://github.com/lordpretzel/radb-mode
;; Keywords:


;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Tree-sitter based major mode for editing radb .ra files.

;;; Code:

;; ********************************************************************************
;; IMPORTS

(require 'treesit)

(declare-function treesit-parser-create "treesit.c")

;; ********************************************************************************
;; CUSTOM
(defvar radb-mode--treesit-settings
  (treesit-font-lock-rules
   :default-language 'radb

   :feature 'string
   :override t
   '((STRING) @font-lock-string-face)

   :feature 'string
   :override t
   '((NUMBER (INTEGER)) @font-lock-constant-face)

   :feature 'attribute
   :override t
   '((attr) @font-lock-type-face)

   :feature 'view-name
   :override t
   '((view viewname: (IDENTIFIER) @font-lock-variable-name-face))

   :feature 'function-calls
   :override t
   '((agg_function) @font-lock-function-name-face)

   :feature 'function-calls
   :override t
   '((agg_function) @font-lock-function-name-face)

   :feature 'table-name
   :override t
   '((tableaccess tablename: (IDENTIFIER) @font-lock-variable-name-face))

   :feature 'keyword
   :override t
   '((DEFAS) @font-lock-keyword-face
     (PROJECT) @font-lock-keyword-face
     (SELECT) @font-lock-keyword-face
     (RENAME) @font-lock-keyword-face
     (KWJOIN) @font-lock-keyword-face
     (KWCROSS) @font-lock-keyword-face
     (KWUNION) @font-lock-keyword-face
     (KWDIFFERENCE) @font-lock-keyword-face
     (KWINTERSECTION) @font-lock-keyword-face
     (AGGREGATION) @font-lock-keyword-face
     (LIST) @font-lock-keyword-face
     (SOURCE) @font-lock-keyword-face
     (QUIT) @font-lock-keyword-face
     (SAVE) @font-lock-keyword-face
     (SQLEXEC) @font-lock-keyword-face)

   :feature 'delimiter
   :override t
   '((["," ";"]) @font-lock-delimiter-face)

   :feature 'bracket
   '((["(" ")" "{" "}"]) @font-lock-bracket-face)

   :feature 'operator
   '((["=" "<" ">" "<=" ">="]) @font-lock-operator-face)

   :feature 'string
   :override t
   '((COMMENT) @font-lock-comment-face)
   )
  "Tree-sitter font-lock settings.")

(defcustom radb-mode-indent-offset
  4
  "Number of spaces for one level of indentation."
  :group 'radb-mode
  :type 'number)

(defvar radb-mode--indent-rules
  `((radb
       ((node-is ")") parent 0)
       ((node-is "view") parent-bol 0)
       ((node-is "query") parent-bol 0)
       ((node-is "utility") parent-bol 0)
       ((and (parent-is ,(rx (or "projection"
                         "selection"
                         "rename"
                         "aggregation")))
             (node-is "comment")) parent radb-mode-indent-offset)
       ((and (parent-is ,(rx (or "union"
                         "join"
                         "difference"
                         "intersection")))
             (node-is "comment")) parent 0)
       ((node-is "comment") column-0 0)
       ((field-is "leftinput") parent 0)
       ((field-is "rightinput") first-sibling 0)
       ((node-is "KWUNION") first-sibling 0)
       ((node-is "KWJOIN") first-sibling 0)
       ((node-is "KWCROSS") first-sibling 0)
       ((node-is "KWDIFFERENCE") first-sibling 0)
       ((node-is "KWINTERSECTION") first-sibling 0)
       ((field-is "^input$") parent radb-mode-indent-offset)
       ((match nil "selection" "condition" nil nil) parent 9)
       ((match nil "join" "condition" nil nil) parent 5)
       ((query "(projection ((_) @ident))") parent 10)
       ((query "(rename ((_) @ident))") parent 9)
       ((catch-all) column-0 0)))
  "Tree-sitter indentation rules.")

;; ********************************************************************************
;; FUNCTIONS
(defun radb-mode--ts-imenu-name (node)
  "Get name for imenu element for treesit NODE."
  (pcase (treesit-node-type node)
    ("view"
     (treesit-node-text
      (treesit-search-subtree
       (treesit-node-child-by-field-name node "viewname")
       "IDENTIFIER")))
    ("utility"
     (replace-regexp-in-string "\\\\" ""
     (treesit-node-text
      (treesit-node-child-by-field-name
       (treesit-node-child node 0)
       "command"))))
    (_
     (substring (treesit-node-text node) 0 40))))

(defun radb-mode--treesit-defun-name (node)
  "Treesit node types NODE defined to be defuns."
  (pcase (treesit-node-type node)
    ((or "view" "utility")
     (radb-mode--treesit-is-imenu-entry node))
    (_ nil)))

(defun radb-mode--treesit-is-imenu-entry (node)
  "Return non-nil if NODE is should be an imenu entry."
  (pcase (treesit-node-type node)
    ("view"
     t)
    ("utility"
     t)
    ("query"
     (not (treesit-parent-until node "view")))))

;; ********************************************************************************
;; MODE DEFINITION

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ra\\'" . radb-mode))

;;;###autoload
(define-derived-mode radb-mode prog-mode "radb"
  "Major mode for editing radb relational algebra files.

This major mode uses the tree-sitter library and grammar from
`https://github.com/lordpretzel/tree-sitter-radb'.

\\{radb-mode-map}"
  ;; :syntax-table python-mode-syntax-table
  (when (treesit-ready-p 'radb)
    (treesit-parser-create 'radb)

    ;; font lock
    (setq-local treesit-font-lock-feature-list
                '((comment keyword view-name table-name)
                  (string function-calls attribute)
                  (number operator delimiter)
                  (bracket)))
    (setq-local treesit-font-lock-settings
                radb-mode--treesit-settings)

    (setq-local treesit-simple-imenu-settings
                `(("Query" "\\`query\\'" radb-mode--treesit-is-imenu-entry radb-mode--ts-imenu-name)
                  ("Utility" "\\`utility\\'" radb-mode--treesit-is-imenu-entry radb-mode--ts-imenu-name)
                  ("View definition" "\\`view\\'" radb-mode--treesit-is-imenu-entry radb-mode--ts-imenu-name)))

    ;; Navigation.
    (setq-local treesit-defun-type-regexp
                (regexp-opt '("query"
                              "view"
                              "utility")))
    (setq-local treesit-defun-name-function #'radb-mode--treesit-defun-name)

    ;; indentation
    (setq-local treesit-simple-indent-rules radb-mode--indent-rules)
    ;; activate tree sitter
    (treesit-major-mode-setup)))


(provide 'radb-mode)
;;; radb-mode.el ends here
