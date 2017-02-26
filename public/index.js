/* eslint no-unused-vars: */
/* eslint no-undef: */

var outputFiles = document.getElementById('output_files')
var textArea = document.getElementById('text-area')
var warning = document.getElementById(':warning')

function populateTextArea () {
  'use strict'
  var string = ''
  for (var i = 0; i < outputFiles.files.length; i++) {
    string = string.concat(outputFiles.files[i].name, '\n')
  }
  textArea.value = string
}

function clearInputs () {
  textArea.value = ''
  outputFiles.value = ''
}

function uploadFiles () {
  'use strict'
  warning.innerText = ''
  if (outputFiles.checkValidity() === false) {
    alert('Please select the files you wish to collate')
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
        warning.innerText = text
      } else {
        warning.innerText = text
      }
    }
    stopTheWheel('home')
  }
}
