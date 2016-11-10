 function AppComponent() {
        this.notes = [];
        this.addTodo = function(note) {
			
				this.notes.push(note.value);
            			note.value = null;
			
            return false;
        }

    }

	function removeTodo(el)
	{
    
    el.parentNode.parentNode.parentNode.parentNode.parentNode.style.display="none";
	}
    AppComponent.annotations = [
      new angular.ComponentAnnotation({
        selector: 'sticky'
      }),
      new angular.ViewAnnotation({
        template:'<div class="row"><div class="col s12 l4 m4><br/></div><div class="col s12 l4 m4"><form (submit)="addTodo(notetext)"><input id="input_text" type="text" maxlength="20" placeholder="enter the note title" #notetext></div><div class="col s12 l4 m4><button class="btn waves-effect waves-light orange accent-3" type="submit"><b>+</b></button></form></div></div>' +
                 '<div class="col s12 l4 m4" *ng-for="#note of notes"><div class="card yellow accent-2"><div class="card-content dark-text"><div class ="row"><div class="input-field col s8"><h5><input value="{{ note }}" type="text" placeholder="note title"></h5></span></div><div class="col s1"><br/></div><div class="col s1"><button class="btn-floating btn-small waves-effect waves-light orange accent-3" onclick="removeTodo(this)">X</button></div></div><div class="input-field"><textarea id="textarea1" class="materialize-textarea" placeholder="notes here"></textarea></div></div></div></div><br/>',
        directives: [angular.NgFor]
      })
    ];

    document.addEventListener('DOMContentLoaded', function() {
      angular.bootstrap(AppComponent);
    });
