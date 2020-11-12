;;;; ambar.lisp

(in-package #:ambar)

(defparameter *stores* '(""))

;; directory where files are located
(defparameter *root* #p"/home/pi/Downloads/")

(defparameter *Download* "/Download/")

(defparameter *static* "static/")

(setf (cl-who:html-mode) :html5)

(setf hunchentoot:*dispatch-table*
      `(hunchentoot:dispatch-easy-handlers
        ,(hunchentoot:create-folder-dispatcher-and-handler
	  *Download* *root*)
	,(hunchentoot:create-folder-dispatcher-and-handler
	  "/static/" *static*)))

(defmacro with-html-page (&rest body)
  "Basic template for a general-purpose Web page."
  (let ((out (gensym)))
    `(cl-who:with-html-output-to-string (,out nil :prologue t :indent t)
       (:html
	(:head
	 (:title "Ambar")
	 (:meta :name "viewport" :content "width=device-width, initial-scale=1.0")
	 (:link :href "/static/bootstrap/css/bootstrap.min.css" :rel "stylesheet"))
	(:body
	 (:div :class "container-fluid"
	       ,@body)))
       ,out)))

(defun make-breadcrumbs (file-name)
  "Generates breadcrumbs for the given location."

  (cl-who:with-html-output-to-string (out nil :indent t)
    (:nav :aria-label "breadcrumb"
	  (:ol :class "breadcrumb"
	       (:li :class "breadcrumb-item"
		    ;; use Bootstrap icon 'house' to label Root directory
		    (:a :href "/dir?dir-name=."
			(:svg :class "bi" :width "19" :height "19" :fill "currentColor"
			      (:use :|xlink:href| "/static/icons/bootstrap-icons.svg#house"))))
	       (loop for dir in (cdr (pathname-directory file-name))
		     for dir-name = (concatenate 'string "/dir?dir-name=" dir "/")
		       then (concatenate 'string dir-name dir "/")
		     do
			(cl-who:htm
			 (:li :class "breadcrumb-item"
			      (:a :href dir-name
				  (cl-who:str dir)))))))
    out))

(defun make-download-button (file-name)
  (cl-who:with-html-output-to-string (out nil :indent t)
    (:a :class "btn btn-primary" :href (format nil "~a~a" *Download* file-name)
	(:svg :class "bi" :width "19" :height "19" :fill "currentColor"
	      (:use :|xlink:href| "/static/icons/bootstrap-icons.svg#download")))))

(defun image-file-p (file-name)
  (find (string-downcase (pathname-type file-name))
	'("jpg" "gif" "png" "tiff" "jpeg")
	:test #'string-equal))

(defun video-file-p (file-name)
  (find (string-downcase (pathname-type file-name))
	'("avi" "mpg" "mp4" "mov" "3gp")
	:test #'string-equal))

(hunchentoot:define-easy-handler (view :uri "/view")
    ((file-name :parameter-type 'string))
  (cond
    ((image-file-p file-name)
     (with-html-page
	 (cl-who:str (make-breadcrumbs file-name))
       (:div :class "row justify-content-start"
	     (:img :src (format nil "~a~a" *Download* file-name)
		   :class "img-fluid"))
       (:div :class "row justify-content-start"
	     (cl-who:str (make-download-button file-name)))))

    ((video-file-p file-name)
     (with-html-page
	 (cl-who:str (make-breadcrumbs file-name))
       (:video
	:controls t
	(:source :src (format nil "~a~a" *Download* file-name)
		 :type "video/x-msvideo"))
       (cl-who:str (make-download-button file-name))
       ;; todo: more file types support, add support for playback with
       ;; OMX Player on the Pi
       ))

    (t
     (with-html-page
	 (cl-who:str (make-breadcrumbs file-name))
	 (cl-who:str (make-download-button file-name))))))


(hunchentoot:define-easy-handler (dir :uri "/dir")
    ((dir-name :parameter-type 'string :init-form "."))
  (with-html-page
      (:div :class "row justify-content-start"
	    (:div :class "col"
		  (cl-who:str (make-breadcrumbs dir-name))))
    (:div :class "row justify-content-start"
	  (:div :class "col"
		(:table :class "table table-sm"
			(:thead
			 (:tr
			  (:th :scope "col" "Name")))
			(:tbody
			 (dolist (entry (cl-fad:list-directory
					 (cl-fad:merge-pathnames-as-directory *root* dir-name)))
			   (if (cl-fad:directory-pathname-p entry)
			       ;; directory
			       (let ((name (car (last (pathname-directory entry))))
				     (link (format nil "?dir-name=~a" (enough-namestring entry *root*))))
				 (cl-who:htm
				  (:tr
				   (:td
				    (:svg :class "bi" :width "17" :height "17" :fill "currentColor"
					  (:use :|xlink:href| "/static/icons/bootstrap-icons.svg#folder"))
				    (:a :href link
					(cl-who:str name))))))
			       ;; ordinary file
			       (let ((name (file-namestring entry))
				     (link (format nil "/view?file-name=~a" (enough-namestring entry *root*))))
				 (cl-who:htm
				  (:tr
				   (:td
				    (:a :href link
					(cl-who:str name))))))))))))))


(defun run (&optional (root-dir #p"/home/pi/Downloads/"))
  (setf *root* root-dir)
  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor
				    :port 4242)))
