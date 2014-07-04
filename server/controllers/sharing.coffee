async = require 'async'
clearance = require 'cozy-clearance'

Album = require '../models/album'
User = require '../models/user'

LocalizationManager = require '../helpers/localization_manager'
localization = new LocalizationManager

clearanceCtl = clearance.controller
    mailTemplate: (options, callback) ->
        console.log options
        localization.initialize ->
            mailTemplate = localization.getEmailTemplate 'sharemail.jade'
            User.getDisplayName (err, displayName) ->
                options.displayName = displayName or \
                                      localization.t 'default user name'
                options.localization = localization
                callback null, mailTemplate options

    mailSubject: (options, callback) ->
        name = options.doc.title
        User.getDisplayName (err, displayName) ->
            displayName = displayName or localization.t 'default user name'
            callback null, localization.t 'email sharing subject',
                displayName: displayName
                name: name

# fetch file or folder, put it in req.doc
module.exports.fetch = (req, res, next, id) ->
    Album.find id, (err, album) ->
        if album
            req.doc = album
            next()
        else
            err = new Error 'bad usage'
            err.status = 400
            next err

module.exports.change = clearanceCtl.change
module.exports.sendAll = clearanceCtl.sendAll
module.exports.contactList = clearanceCtl.contactList
module.exports.contactPicture = clearanceCtl.contactPicture