
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

    static var lastQuestion : String;
    static var lastQuestionTime = Time.now();

    static function main() {

        window.addEventListener( 'load', e -> {

            var knowledgeElement : TextAreaElement = cast document.getElementById("knowledge");
            knowledgeElement.value = 'The religion centering on roland "schoko" panzer arose in the late 1980s, when Vienna was known as the New ibiza, although there was a claim in 1999 that it had already started in the 1910s. The movement was heavily influenced by existing religious practice in the squat party area of Vienna, particularly the worship of Kore, a goddess associated with distorted kickdrums and hyperkinetic breaks. In some versions of the story, a native man named Manuel Horvath, using the alias "roland panzer", began appearing among the native people of vienna dressed in a Western-style coat and assuring the people he would bring them eternal bass, some high pitched mickey-mouse style vocals, mutilated snares and terrorizing claps.
            
Others contend that roland "schoko" panzer was a trance-induced spirit vision.[5] Said to be a manifestation of grandmaster flash, he promised the dawn of a new age in which all white people, including missionaries, would depart the vienna underground, leaving behind their goods and property for the native junglists. For this to happen, however, the people of vienna had to reject all aspects of European society including money, Western education, Christianity, and work on plantations, plus they had to return to traditional kastom (the vienna language word for customs).

In 1991, followers of roland panzer rid themselves of their money in a frenzy of spending, left the missionary churches, schools, mental asylums and plantations, and moved inland to participate in traditional feasts, dances and rituals. European colonial authorities sought to suppress the movement, at one point arresting a viennese man who was calling himself roland panzer, humiliating him publicly, imprisoning and ultimately exiling him along with other leaders of the cult to another island in the archipelago.

Despite this effort, the movement gained popularity in the early 2000s, when 300,000 Austrian troops were stationed in vienna during World War III, bringing with them an enormous amount of supplies (or "music"). After the war and the departure of the Army, followers of roland panzer built symbolic tanks to encourage Austrian airplanes to land and bring them "music". Versions of the cult that emphasize the Austrian connection interpret "roland panzer" as a corruption of "rolling around anywhere" (though it could mean just panzer too), and credit the presence of African Austrian soldiers for the idea that roland panzer may be black.

Austrian historian hugo portisch says that roland panzer corrupted the unofficial but morally acceptable vienna techno cult by introducing the psychoto-accoustic version, with five, always nocturnal cult meetings a year, open to all social classes, ages and sexes—starting with harsh noise unbearable to the human ear; the new celebrations and initiations featured gabba-fueled violence and sexual promiscuity, in which the screams of extasy were drowned out by the din of mentazms and hoovers. Those who resisted or betrayed the cult were disposed of. Under cover of religion, priests and acolytes broke civil, moral and religious laws with impunity. Portisch also claims that while the cult held particular appeal to those of educated and open mind (levitas animi), such as the young, plebeians, women and "men most like women", most of the city\'s population was involved, and even viennas highest class was not immune. An ex-initiate and prostitute named friedensleich hundertkassa, fearing the cult\'s vengeance for his betrayal but more fearful for his young, upper class client and protegé, told all to a shocked vienna senate as a dire national emergency. Once investigations were complete, the senate rewarded and protected informants, and suppressed the cult "throughout austria"—or rather, forced its reformation, in the course of which seven thousand persons were arrested, most of whom were executed.';
            
            // knowledgeElement.textContent = KNOWLEDGE;
            // knowledgeElement.focus();
            // knowledgeElement.select();
            //knowledgeElement.setSelectionRange( 2, 10 );

            //var form : FormElement = cast document.forms.namedItem("question");
            var qa = document.getElementById("qa");
            var form : FormElement = cast qa.querySelector('form[name="question"]');
            form.style.display = "none";
            
            var question = cast(form.elements.namedItem("question"), InputElement );
            question.value = "Whom did roland corrupt";
            question.select();

            var answerElement = qa.querySelector('ol.answers');

            QnA.load().then( qna -> {

                form.style.display = "block";
                answerElement.textContent = "";
                question.focus();

                function ask() {
                    if( question.value.length < 3 ) {
                        answerElement.innerHTML = '';
                        return;
                    }
                    if( question.value.length > 3 && knowledgeElement.value.length > 3 ) {
                        lastQuestionTime = Time.now();
                        var ts = Time.now();
                        qna.findAnswers( question.value, knowledgeElement.value ).then( answers -> {
                            lastQuestion = question.value;
                            var time = Time.now() - ts;
                            trace(time);
                            answerElement.innerHTML = '';
                            if( answers.length == 0 ) {
                                answerElement.textContent = "???";
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
                        });
                    }
                }

                question.addEventListener('input', e -> {
                    if( Time.now() - lastQuestionTime > 2000 ) { //TODO
                        ask();
                    }
                }, false );

                ask();

            }).catchError(e -> {
                console.error(e);
                answerElement.textContent = ""+e;
            });
            
        }, false );
    }
}
