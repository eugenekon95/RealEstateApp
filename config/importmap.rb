# frozen_string_literal: true

pin 'application', preload: true
pin "popper", to: 'popper.js', preload: true
pin "bootstrap", to: 'bootstrap.min.js', preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.1.0/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "stimulus-lightbox", to: "https://ga.jspm.io/npm:stimulus-lightbox@3.0.0/dist/stimulus-lightbox.es.js"
pin "lightgallery", to: "https://ga.jspm.io/npm:lightgallery@2.6.0/lightgallery.es5.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

