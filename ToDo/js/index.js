 function AppComponent() {
        this.todos = [];
        this.addTodo = function(todo) {
            this.todos.push(todo.value);
            todo.value = null;
            return false;
        }
    }
    
    AppComponent.annotations = [
      new angular.ComponentAnnotation({
        selector: 'todo'
      }),
      new angular.ViewAnnotation({
        template: '<h3>Tasks</h3>' +
                  '<ul  class="collection"><li class="collection-item" *ng-for="#todo of todos">&nbsp;{{ todo }}</li><br/></ul>' +
                  '<form (submit)="addTodo(todotext)"><input #todotext><button class="btn waves-effect waves-light" type="submit">add</button></form>',
        directives: [angular.NgFor]
      })
    ];
    
    document.addEventListener('DOMContentLoaded', function() {
      angular.bootstrap(AppComponent);
    });
