// Initialize editor with custom theme and modules
var fullEditor = new Quill('#full-editor', {
  modules: {
    'authorship': { enabled: true },
    'multi-cursor': true,
    'toolbar': { container: '#full-toolbar' },
    'link-tooltip': true
  },
  theme: 'snow'
});

// Add basic editor's author
var authorship = fullEditor.getModule('authorship');
authorship.addAuthor('gandalf', 'rgba(255,153,51,0.4)');

// Add a cursor to represent basic editor's cursor
var cursorManager = fullEditor.getModule('multi-cursor');
cursorManager.setCursor('gandalf', fullEditor.getLength()-1, 'Gandalf', 'rgba(255,153,51,0.9)');


// Update basic editor's content with ours
fullEditor.on('text-change', function(delta, source) {
  if (source == 'user') {
    // basicEditor.updateContents(delta);
  }
});


// Post to the sinatra app
$('#post_button').click(function() {
  var url = "http://localhost:4567/document";
  var content = fullEditor.getContents();
  var html = fullEditor.getHTML();
  console.log(content);
  $.ajax({
    type: "POST",
    url: url,
    data: {content: JSON.stringify(content)},
    success: function(response) {
      alert("worked");
    }
  });
});
