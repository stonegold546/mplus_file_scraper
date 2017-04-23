/* eslint no-unused-vars: */
/* eslint no-undef: */

var outputFiles = document.getElementById('output_files')
var textArea = document.getElementById('text-area')
var collateWarning = document.getElementById(':collateWarning')
var maxClasses = document.getElementById('max_num_classes')
var lcaInpArea = document.getElementById('lca_inp_area')
var lcaInpWarning = document.getElementById(':lcaInpWarning')
var mplusType = document.getElementById('mplus_type')
var sysOs = document.getElementById('sys_os')

function populateTextArea () {
  'use strict'
  var string = ''
  for (var i = 0; i < outputFiles.files.length; i++) {
    string = string.concat(outputFiles.files[i].name, '\n')
  }
  textArea.value = string
}

function clearInputs (group) {
  if (group === 1) {
    lcaInpArea.value = ''
    maxClasses.value = ''
    lcaInpWarning.innerText = ''
    mplusType.value = 'mplus'
    sysOs.value = 'unix'
  } else if (group === 2) {
    textArea.value = ''
    outputFiles.value = ''
    collateWarning.innerText = ''
  }
}

function uploadFiles () {
  'use strict'
  collateWarning.innerText = ''
  if (outputFiles.checkValidity() === false) {
    alert('Please select the files you wish to collate')
    outputFiles.focus()
    return
  } else {
    var myResult = new XMLHttpRequest()
    var outputFilesFormData = new FormData()
    var url = '/files'
    for (var i = 0; i < outputFiles.files.length; i++) {
      outputFilesFormData.append(outputFiles.files[i].name, outputFiles.files[i])
    }
    spinTheWheel('home')
    myResult.open('post', url, true)
    myResult.send(outputFilesFormData)
    myResult.onreadystatechange = function () {
      var text = myResult.responseText
      if (myResult.readyState === 4 && myResult.status === 200) {
        var blob = new Blob([text], {type: 'text/csv'})
        var elem = window.document.createElement('a')
        elem.href = window.URL.createObjectURL(blob)
        elem.download = 'result.csv'
        document.body.appendChild(elem)
        elem.click()
        document.body.removeChild(elem)
        window.URL.revokeObjectURL(elem.href)
      } else if (myResult.readyState === 4 && myResult.status === 400) {
        collateWarning.innerText = text
      } else if (myResult.readyState === 4 && myResult.status === 500) {
        collateWarning.innerText = 'Server crash! This should not happen. You probably have a non-text output file in there.'
      }
    }
    stopTheWheel('home')
  }
}

function inpUpload () {
  'use strict'
  lcaInpWarning.innerText = ''
  if (maxClasses.checkValidity() === false) {
    alert('Please select a maximum number of classes between than 2 and 20 inclusive.')
    maxClasses.focus()
    return
  } else if (lcaInpArea.value === '') {
    alert('Please copy and paste your input file into the text area.')
    lcaInpArea.focus()
    return
  } else {
    var myResult = new XMLHttpRequest()
    var lcaInps = new FormData()
    var url = '/lca_inps'
    lcaInps.append(maxClasses.id, maxClasses.value)
    lcaInps.append(lcaInpArea.id, lcaInpArea.value)
    lcaInps.append(mplusType.id, mplusType.value)
    lcaInps.append(sysOs.id, sysOs.value)
    spinTheWheel('home')
    myResult.open('post', url, true)
    myResult.send(lcaInps)
    myResult.onreadystatechange = function () {
      var text = myResult.responseText
      if (myResult.readyState === 4 && myResult.status === 200) {
        var elem = window.document.createElement('a')
        var scriptType, scriptName
        if (sysOs.value === 'windows') {
          scriptType = 'application/x-bat'
          scriptName = 'mplus_lca.bat'
        } else {
          scriptType = 'application/x-shellscript'
          scriptName = 'mplus_lca.command'
        }
        var blob = new Blob([text], {type: scriptType})
        elem.href = window.URL.createObjectURL(blob)
        elem.download = scriptName
        document.body.appendChild(elem)
        elem.click()
        document.body.removeChild(elem)
        window.URL.revokeObjectURL(elem.href)
      } else if (myResult.readyState === 4 && myResult.status === 400) {
        lcaInpWarning.innerText = text
      } else if (myResult.readyState === 4 && myResult.status === 500) {
        lcaInpWarning.innerText = 'Server crash! This should not happen. You probably have a non-text output file in there.'
      }
    }
    stopTheWheel('home')
  }
}
