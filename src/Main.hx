
import js.Browser.console;
import js.Browser.document;
import js.Browser.window;
import js.html.FormElement;
import js.html.DivElement;
import js.html.InputElement;
import js.html.TextAreaElement;
import js.lib.Promise;
import om.Time;
import om.tfjs.QnA;

class Main {

    static var STORAGE_PREFIX = "qna_";

    static var knowledgeElement : TextAreaElement;
    static var questionElement : InputElement;

    static var lastQuestion : String;
    static var lastQuestionTime = Time.now();

    static function main() {

        var storage = window.localStorage;

        window.addEventListener( 'load', e -> {

            knowledgeElement = cast document.getElementById("knowledge");
            var knowledge = storage.getItem( '${STORAGE_PREFIX}knowledge' );
            if( knowledge != null ) knowledgeElement.value = knowledge;
            // knowledgeElement.focus();
            // knowledgeElement.select();
            //knowledgeElement.setSelectionRange( 2, 10 );

            var qa = document.getElementById("qa");
            var form : FormElement = cast qa.querySelector('form[name="question"]');
            form.style.display = "none";
            
            questionElement = cast form.elements.namedItem("question");
            var question = storage.getItem( '${STORAGE_PREFIX}question' );
            if( question != null ) questionElement.value = question;
            questionElement.select();

            var answerElement = qa.querySelector('ol.answers');
            var footer = document.body.querySelector('footer');

            QnA.load().then( qna -> {

                form.style.display = "block";
                answerElement.textContent = "";
                questionElement.focus();

                function ask() {
                    if( questionElement.value.length < 3 ) {
                        answerElement.innerHTML = '';
                        return;
                    }
                    if( questionElement.value.length > 3 && knowledgeElement.value.length > 3 ) {
                        lastQuestionTime = Time.now();
                        var ts = Time.now();
                        qna.findAnswers( questionElement.value, knowledgeElement.value ).then( answers -> {
                            console.group( "SEARCH" );
                            lastQuestion = questionElement.value;
                            var time = Time.now() - ts;
                            console.info( time );
                            footer.textContent = Std.int(time)+'MS';
                            answerElement.innerHTML = '';
                            if( answers.length == 0 ) {
                                answerElement.textContent = "No results";
                            } else {
                                for( answer in answers ) {
                                    trace(answer);
                                    var li = document.createLIElement();
                                    li.classList.add( 'answer' );
                                    li.onclick = _ -> {
                                        //trace(answer.startIndex, answer.endIndex );
                                        knowledgeElement.focus();
                                        knowledgeElement.setSelectionRange( answer.startIndex, answer.endIndex );
                                    }
                                    var text = document.createDivElement();
                                    text.textContent = answer.text;
                                    li.append( text );
                                    var meta = document.createDivElement();
                                    meta.classList.add('meta');
                                    meta.textContent = ''+Std.int( answer.score*1000)/1000;
                                    meta.textContent += ' / '+answer.startIndex+'-'+answer.endIndex;
                                    li.append( meta );
                                    answerElement.append( li );
                                }
                            }
                            console.groupEnd();
                        });
                    }
                }

                questionElement.addEventListener('input', e -> {
                    //TODO
                    if( questionElement.value.length < 3 || knowledgeElement.value.length < 3 ) {
                        return;
                    }
                    if( Time.now() - lastQuestionTime > 2000 ) { //TODO
                        ask();
                    }
                }, false );

                //ask();

            }).catchError(e -> {
                console.error(e);
                answerElement.textContent = ""+e;
            });
            
        }, false );

        window.onbeforeunload = e -> {
            if( knowledgeElement != null && knowledgeElement.value.length > 0 ) {
                storage.setItem( '${STORAGE_PREFIX}knowledge', knowledgeElement.value );
            }
            if( questionElement != null && questionElement.value.length > 0 ) {
                storage.setItem( '${STORAGE_PREFIX}question', questionElement.value );
            }
            e.preventDefault();
            e.returnValue = true;
            return null;
        }
    }
}
