/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import js.html.Blob;
import saturn.core.scarab.LabPageImage;
import saturn.core.scarab.LabPageText;
import saturn.core.scarab.LabPage;
import saturn.client.programs.SimpleExtJSProgram;

import saturn.client.workspace.ScarabELNWO;

import saturn.client.workspace.Workspace.WorkspaceObject;
import saturn.util.StringUtils;

import bindings.Ext;

class ScarabELNViewer extends SimpleExtJSProgram{
    static var CLASS_SUPPORT : Array<Class<Dynamic>> = [ ScarabELNWO ];

    var theComponent : Dynamic;
    var editor : Dynamic;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        theComponent = Ext.create('Ext.panel.Panel', {
            width:'100%',
            height: '100%',
            autoScroll : true,
            region:'center',
            listeners : {
                'afterrender' : function() {
                    initialiseDOMComponent();
                }
            },
            autoEl: { tag: 'div', html: ""	}
        });
    }

    override public function initialiseDOMComponent() {
        super.initialiseDOMComponent();
    }

    override
    public function onFocus(){
        super.onFocus();

        getApplication().getToolBar().add({
            iconCls :'x-btn-copy',
            text:'Example Button'
        });

        getApplication().getEditMenu().add({
            text : "Click me",
            handler : function(){
                getApplication().showMessage('Menu','You clicked me!');
            }
        });

        getApplication().hideMiddleSouthPanel();
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        var w0 : ScarabELNWO = cast(super.getActiveObject(ScarabELNWO), ScarabELNWO);
        var obj : LabPage= cast(w0.getObject(), LabPage);

        // We fetch and then activate incase meta-data fields on LabPage aren't initialised (i.e. when a session is being restored)
        getProvider().getById(obj.experimentNo, LabPage, function(obj : LabPage, err : String){
            w0.setObject(obj);
            if(err != null){
                getApplication().showMessage('',err);
            }else{
                getProvider().activate([obj], 4, function(err : String){
                    setTitle(w0.getName());



                    renderPage();
                });
            }
        });
    }

    override public function setTitle(title : String){
        if(theComponent.tab != null){
            theComponent.tab.setText(title);
        }
    }


    override public function getComponent() : Dynamic {
        return theComponent;
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
            {
                iconCls :'x-btn-dna',
                text:'ScarabELNViewer',
                cls: 'quickLaunchButton',
                handler: function(){
                    WorkspaceApplication.getApplication().getWorkspace().addObject(new ScarabELNWO(null, null), true);
                }
            }
        ];
    }

    public function getDomElement() : js.html.Element{
        return theComponent.getEl().down('div[id*=innerCt]').dom;
    }

    public function renderPage(){
        var obj : LabPage = getActiveObjectObject();

        var container : js.html.DivElement = cast getDomElement();
        for(child in container.childNodes){
            container.removeChild(child);
        }

        container.className = 'scarab_page';

        var headerDiv = js.Browser.document.createDivElement();
        headerDiv.className = 'scarab_header';

        var titleDiv = js.Browser.document.createDivElement();
        titleDiv.innerText = 'Title: ' + obj.title;
        titleDiv.className = 'scarab_title';

        var authorDiv = js.Browser.document.createDivElement();
        authorDiv.innerText = 'Author: ' + obj.userObj.fullName;
        authorDiv.className = 'scarab_author';

        var dateDiv = js.Browser.document.createDivElement();

        if(obj.dateStarted != null && Reflect.hasField(obj.dateStarted, 'getDate')){
            dateDiv.innerText = 'Created: ' + obj.dateStarted.getDate() + '/' + (obj.dateStarted.getMonth() + 1) + '/' + obj.dateStarted.getFullYear();
            dateDiv.className = 'scarab_date';
        }

        var dateUpdatedDiv = js.Browser.document.createDivElement();
        dateUpdatedDiv.innerText = 'Created: ' + obj.lastEdited.getDate() + '/' + (obj.lastEdited.getMonth() + 1) + '/' + obj.lastEdited.getFullYear();
        dateUpdatedDiv.className = 'scarab_date_updated';

        headerDiv.appendChild(titleDiv);
        headerDiv.appendChild(authorDiv);
        headerDiv.appendChild(dateDiv);
        headerDiv.appendChild(dateUpdatedDiv);

        container.appendChild(headerDiv);

        var counter : Int = 1;

        for(item in obj.items){
            if(!Std.is(item, LabPageText) && !Std.is(item, LabPageImage)){
                continue;
            }

            var captionDiv = js.Browser.document.createDivElement();
            captionDiv.innerText = item.caption;

            container.appendChild(captionDiv);

            var sectionDiv = js.Browser.document.createDivElement();
            sectionDiv.className = 'scarab_section';
            sectionDiv.id = 'scarab_section' + '_' + counter;

            sectionDiv.style.width = '100%';

            sectionDiv.ondblclick = doubleClickHandler;

            if(Std.is(item, LabPageText)){
                var textSection :LabPageText = cast item;
                var iframe = js.Browser.document.createIFrameElement();
                iframe.srcdoc = textSection.content;

                //useful custom attributes to identify which section was updated/changed
                iframe.setAttribute('data-caption',textSection.caption);
                iframe.setAttribute('data-elnsectionid',Std.string(textSection.elnSectionId));
                iframe.setAttribute('data-sectionid',Std.string(textSection.id));
                iframe.setAttribute('data-sectionorder',Std.string(textSection.itemOrder));

                /*
                 * iframe.onload to resize the sections when the page is loaded into the dom/context
                 *
                 * iframe.onchange is triggered manually after ckeditor instance is destroyed, so the
                 * iframe is resized with respect to the new content
                 */
                iframe.onload =  iframeResizeHandler;
                iframe.onchange = iframeResizeHandler;

                iframe.width = '100%';
                iframe.style.marginTop = '5px';
                iframe.style.maxHeight = '400';
                iframe.scrolling = 'auto';

                iframe.setAttribute('seamless', 'seamless');

                iframe.className = 'scarab_text_read';
                iframe.id = 'scarab_text_read' + '_' + counter;

                sectionDiv.appendChild(iframe);
            }else if(Std.is(item, LabPageImage)){
                var imageSection :LabPageImage = cast item;
                var image = js.Browser.document.createImageElement();

                var window :Dynamic = js.Browser.window;

                var blob = new Blob( [ imageSection.imageEdit ], { type: "image/jpeg" } );

                var urlCreator :Dynamic = window.URL || window.webkitURL;
                var imageUrl = urlCreator.createObjectURL( blob );
                image.src = imageUrl;

                image.style.maxWidth = '100%';
                image.style.maxHeight = '400px';
                image.style.display = 'block';
                image.style.marginTop = '5px';

                sectionDiv.appendChild(image);

                image.className = 'scarab_image_read';
                image.id = 'scarab_image_read' + '_' + counter;
            }

            container.appendChild(sectionDiv);
            counter++;
        }
    }

    /*
     * Double click handler is attached to the div containing the iframe. It is responsible for
     * attaching ckeditor to the content of the iframe within double clicked div tag
     */
    private function doubleClickHandler(event: Dynamic) : Void {
        var sectionDiv : Dynamic;
        var config : Dynamic = {};

        untyped {
            // This option makes it possible to set additional allowed content rules
            config.allowedContent = true;
            config.extraAllowedContent = 'span;ul;li;table;td;style;*[id];*(*);*{*}';

            if ( editor ) {
                //editor name would always be the id of the element to which it is attached
                var iframeId = editor.name;

                //replace the content of the iframe with the content of the editor
                $('#' + iframeId).contents().find('body').html(editor.getData());

                updateActiveObject(iframeId);

                editor.destroy();

                /* trigging the on change event manually so the iframe is resized to its content size */
                $('#' + iframeId).trigger("change");
            }

            sectionDiv = $(event.target) || $(event.srcElement);

            //the default styles to be added to the ckeditor.
            //var styles = $(sectionDiv).children().first().contents().find('body').attr('style');

            var iframeId = $(sectionDiv).children().first().attr('id');

            //attaching ckeditor to the iframe
            editor = CKEDITOR.replace(iframeId, config);

            //set content of the editor to the content of the iframe that is double clicked
            editor.setData($(sectionDiv).children().first().contents().find('body').html());
        }
    }

    /*
     * Invoked by iframe onload and change events, responsible for resizing the section
     */
    private function iframeResizeHandler(event : Dynamic) : Void {
        untyped {
            var element = event.target || event.srcElement;

            //offsetHeight returns the exact height of the content, 30px added to introduce space around content
            element.style.height = (element.contentWindow.document.body.offsetHeight + 30) + 'px';
        }
    }

    private function updateActiveObject(iframeId: String) : Void {
        var obj : LabPage = getActiveObjectObject();
        var temp : LabPageText = null;
        var itemId : String = null;

        untyped {
            itemId = $('#' + iframeId).attr('data-sectionid');
        }

        for(item in obj.items) {
            if(Std.is(item, LabPageText) && Std.string(item.id) == itemId) {
                temp = cast item;
                obj.items.remove(item);
                untyped {
                    var iframeContent = $('#' + iframeId).contents().find('body').html();
                    temp.content = constructScarabCompatibleHtml(iframeId, iframeContent);
                }
                obj.items.push(temp);
                break;
            } else {
                continue;
            }
        }

        //provider call to send back the object with updated section
        getApplication().getProvider().update(temp, updateCallBack);
    }

    private function updateCallBack() : Void {
        //Update callback
    }

    /*
     * This method is aimed to strip off the doctype, head, styles, html tags of iframe srcdoc content and
     * add the tags to the newly generated HTML body via ckeditor so it is compatible for Scarab QT Rich Text Editor
     */
    private function constructScarabCompatibleHtml(iframeId: String, iframeContent: Dynamic) {
        var content: Dynamic = null;
        untyped {
            var iframeSource = $('#' + iframeId).attr('srcdoc');
            var header = iframeSource.split('<body')[0];
            var fullBody = iframeSource.split('</head>')[1];
            var bodyOpenningTag = fullBody.split('>')[0] + '>';

            content = header + bodyOpenningTag + iframeContent + '</body></html>';
        }
        return content;
    }
}
