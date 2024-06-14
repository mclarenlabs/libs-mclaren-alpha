;; simple steptalk highlighting based on generic-mode
;;
;; load it by putting this in your init.el file
;;   (load-file "~/.emacs.d/steptalk.el")
;;
;; McLaren Labs 2024

(define-generic-mode 'steptalk

  ;; no end-of-line comment in StepTalk
  nil

  ;; keyword list
  (list "Transcript" ":=" "self" "true" "false" "ifTrue:" "ifFalse:" "do:")

  ;; font-locks
  '(
    ;; #selector
    ("\\(#[[:alnum:]_][[:alnum:]_:]*\\)" 1 font-lock-constant-face)
    ;; functionName:
    ("\\([[:alnum:]_]+:\\)" 1 font-lock-function-name-face)
    ;; ClassName
    ("\\<[[:upper:]][[:alnum:]_]*\\>" 0 font-lock-type-face)
    ;; :varible
    (":[[:lower:]][[:alnum:]_]*" . font-lock-variable-name-face)
    ;; match open | as long as it is not part of [|
    ;; | <sp> vars* <sp> |
    ("[^[]|\\(\\s-*[[:alnum:]_]\\)*\\s-*|" . font-lock-variable-name-face)
    )

  ;; auto-mode-list
  (list "\\.st$")

  ;; function list
  (list
   (lambda ()
     ;; make single  quote a string
     (modify-syntax-entry ?' "\"")
     ;; Comment (generic)
     (modify-syntax-entry ?\" "!   ")

     ))

  "StepTalk")

     
