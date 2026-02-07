#!/usr/bin/env txr
;; Tiny text adventure in TXR Lisp

(defvar *room* 'start)
(defvar *inventory* nil)
(defvar *running* t)

(defvar *rooms*
  '((start "You are in a dark cave. Exits: north, east."
           ((north . forest) (east . river)))
    (forest "You are in a dense forest. A key glints on the ground. Exits: south, east."
            ((south . start) (east . castle)))
    (river "You are by a rushing river. Exits: west."
           ((west . start)))
    (castle "You stand before a locked castle door. Exits: west."
            ((west . forest)))))

(defun describe-room ()
  (let ((room-data (assoc *room* *rooms*)))
    (put-line (cadr room-data))
    (when *inventory*
      (put-line `Inventory: @{*inventory* ", "}`))))

(defun go-direction (dir)
  (let* ((room-data (assoc *room* *rooms*))
         (exits (caddr room-data))
         (dest (cdr (assoc dir exits))))
    (if dest
        (set *room* dest)
        (put-line "You can't go that way."))))

(defun take-item ()
  (cond
    ((and (eq *room* 'forest) (not (member 'key *inventory*)))
     (push 'key *inventory*)
     (put-line "You pick up the key."))
    (t (put-line "Nothing to take here."))))

(defun open-door ()
  (cond
    ((and (eq *room* 'castle) (member 'key *inventory*))
     (put-line "You unlock the door and enter the castle. You win!")
     (set *running* nil))
    ((eq *room* 'castle)
     (put-line "The door is locked. You need a key."))
    (t (put-line "There's no door here."))))

(put-line "=== Tiny Adventure ===")
(put-line "Commands: north, south, east, west, take, open, quit\n")

(while *running*
  (describe-room)
  (put-string "> ")
  (let ((cmd (downcase-str (get-line))))
    (cond
      ((member cmd '("north" "south" "east" "west"))
       (go-direction (intern cmd (find-package "pub"))))
      ((equal cmd "take") (take-item))
      ((equal cmd "open") (open-door))
      ((equal cmd "quit") (set *running* nil))
      (t (put-line "Unknown command.")))))

(put-line "Thanks for playing!")
