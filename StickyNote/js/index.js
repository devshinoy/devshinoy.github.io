 function AppComponent() {
        this.notes = [];
        this.addTodo = function(note) {
			if(note.value!=="")
			{
				this.notes.push(note.value);
            note.value = null;
			}	
            return false;
        }

    }
	
	function removeTodo()
	{
    el = document.getElementsByClassName('col s12 l4 m4')[0];
		el.style.display="none";
	}
    AppComponent.annotations = [
      new angular.ComponentAnnotation({
        selector: 'sticky'
      }),
      new angular.ViewAnnotation({
        template: '<div class="col s12 l4 m4" *ng-for="#note of notes"><div class="card yellow accent-4"><div class="card-content dark-text"><div class ="row"><div class="input-field col s8"><input value="{{ note }}" type="text"></span></div><div class="col s4"><button class="btn-floating btn-large waves-effect waves-light orange accent-3" onclick="removeTodo()">X</button></div></div><div class="input-field"><textarea id="textarea1" class="materialize-textarea" placeholder="enter your notes here"></textarea></div></div></div></div><br/>' +
                  '<div class="row"><div class="col s12 l4 m4"><br/></div><div class="col s12 l4 m4"><form (submit)="addTodo(notetext)"><input id="input_text" type="text" maxlength="20"   placeholder="enter the note title" #notetext><button class="btn waves-effect waves-light orange accent-3" type="submit"><b>+</b></button></form></div></div>',
        directives: [angular.NgFor]
      })
    ];

    document.addEventListener('DOMContentLoaded', function() {
      angular.bootstrap(AppComponent);
    });
