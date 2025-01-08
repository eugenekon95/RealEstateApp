// Import and register all your controllers from the importmap under controllers/*
// app/javascript/controllers/index.js

import {Application} from "stimulus"
import Lightbox from "stimulus-lightbox"

const application = Application.start()
application.register("lightbox", Lightbox)
