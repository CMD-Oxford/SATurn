/*
* SATURN (Sequence Analysis Tool - Ultima regula natura)
* Written in 2018 by David Damerell <david.damerell@sgc.ox.ac.uk>, Claire Strain-Damerell <claire.damerell@sgc.ox.ac.uk>, Brian Marsden <brian.marsden@sgc.ox.ac.uk>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

package saturn.client.programs;

import saturn.client.programs.SimpleExtJSProgram;
import saturn.core.domain.TiddlyWiki;
import bindings.Ext;
import saturn.client.core.CommonCore;

/**
* The TiddlyWikiViewer widget provides a wrapper around Tiddly Wiki
* a single page self-contained wiki engine.  The wrapper allows for
* pages to be viewed, edited, and saved back to the database behind
* the default provider
*
* http://tiddlywiki.com/
**/
class TiddlyWikiViewer extends SimpleExtJSProgram{

    //Main widget
    var theComponent : Dynamic;

    public function new(){
        super();
    }

    override public function emptyInit() {
        super.emptyInit();

        var self : TiddlyWikiViewer   = this;

        theComponent = Ext.create('Ext.panel.Panel', {
            width:'100%',
            height: '95%',
            autoScroll : true,
            layout : 'fit',
            items : [{
                xtype : "component",
                autoEl : {
                    tag : "iframe"
                }
            }],
            listeners : {
                'render' : function() {
                    self.initialiseDOMComponent();
                }
            }
        });
    }

    override public function onFocus(){
        super.onFocus();

        getApplication().hideMiddleSouthPanel();
    }
    
    /**
    * getDefaultTemplateTiddlyWiki returns the default wiki template
    **/
    public function getDefaultTemplateTiddlyWiki(cb : String->TiddlyWiki->Void){
        //Get provider instance
        //var provider = getApplication().getProvider();

        CommonCore.getContent('/static/emptywiki.html', function(content){
            var page = new TiddlyWiki();
            page.content = content;

            var d: Dynamic = js.Browser.window;
            d.content = content;

            cb(null, page);
        }, function(err){
            cb('Unable to download template page', null);
        });
    }

    override public function setActiveObject(objectId : String) {
        super.setActiveObject(objectId);

        //Add custom code to handle workspace object being associated with program

        if(objectId != null){
            //Get TiddlyWiki object from workspace object
            var obj : TiddlyWiki = getEntity();

            if(obj.content == null){
                //We get here if the wiki is new and hasn't yet been saved

                //Obtain the default template wiki (first lookup will be slow)
                getDefaultTemplateTiddlyWiki(function(err, template){
                    if(err != null){
                        //We get here if we couldn't retrieve the template
                        getApplication().showMessage('Template error','Unable to retrieve template');
                    }else{
                        //We get here if we have the template
                        obj.content = template.content;

                        //Ask user for new page ID (in the future we might automatically generate
                        getApplication().userValuePrompt('Wiki ID', 'Enter ELN ID', function(pageId){
                            //We get when the user enters an ID and clicks OK

                            //Add wiki ID to newly created TiddlyWiki object
                            obj.pageId = pageId;

                            getWorkspace().renameWorkspaceObject(getActiveObjectId(), pageId);

                            //Get data provider
                            var provider = getApplication().getProvider();

                            //Insert new TiddlyWiki into database
                            provider.insert(obj, function(err){
                                if(err != null){
                                    //We get here if the database returned an error
                                    getApplication().showMessage('Save failure',' Unable to save new page');
                                }else{
                                    //We get here if the save was successful

                                    //Set iframe content to the default Wiki template
                                    setTiddlyWikiContent(obj.content);
                                }
                            });

                            //Mark TiddlyWiki as clean to prevent dialog being shown if the user navigates away
                            //setTiddlyWikiClean();

                            //Set tab title to wiki ID
                            setTitle(pageId);

                            //Set workspace object to wiki ID
                            obj.pageId = pageId;

                            //Reload workspace for workspace object name change to be shown
                            //TODO: Update the label directly as a full reload can take time
                            getApplication().getWorkspace().reloadWorkspace();
                        }, function(){
                            //We get here if the user clicks "Cancel" when entering a ID for the wiki
                            //TODO: clean up gracefully from this
                        });
                    }
                });
            }else{
                //We get here if the TiddlyWiki object has already been saved to the database
                setTiddlyWikiContent(obj.content);

                //Set the tab title to the wiki ID
                setTitle(obj.pageId);
            }
        }
    }

    override public function saveObject(cb : String->Void){
        var obj :TiddlyWiki = getEntity();

        obj.content = getTiddlyWikiContent();

        super.saveObject(function(error){
            cb(error);

            if(error != null){
                setTiddlyWikiClean();
            }
        });
    }

    override public function setTitle(title : String){
        //Set the title of our widget in the tab container
        theComponent.setTitle(title);
    }

    override public function getComponent() : Dynamic {
        //Return our iframe widget
        return theComponent;
    }

    public function getIframe() : Dynamic{
        return theComponent.items.items[0].getEl().dom;
    }

    /**
    * setTiddlyWikiClean inform the native Tiddly Wiki JavaScript that we have saved the changes.
    *
    * Without calling this after a save, Tiddly Wiki will ask the user if they are sure they wish
    * to close the current page if the page is closed or the URL changed.
    **/
    public function setTiddlyWikiClean(){
        //Get the ExtJS iframe object
        var iframe = getIframe();

        if(iframe != null){
            //Get the iframe dom element from the ExtJS iframe object
            //var iframe = element.getEl().dom;

            haxe.Timer.delay(function(){
                //Tell Tiddly Wiki all changes have been saved
                iframe.contentWindow.$tw.syncer.taskQueue = {};
            }, 2000);
        }
    }

    /**
    * setTiddlyWikiContent sets the HTML content of the iframe widget
    *
    * @param content: HTML content
    **/
    public function setTiddlyWikiContent(content : String) : Void {
        //Get ExtJS iframe object
        var iframe = getIframe();

        if(iframe != null){
            //Get the iframe dom element from the ExtJS iframe object
            //var iframe = element.getEl().dom;

            //Find appropriate document object
            var iframeDoc : Dynamic = null;

            if(iframe.contentDocument != null){
                iframeDoc = iframe.contentDocument;
            }else if(iframe.contentWindow.document != null){
                iframeDoc = iframe.contentWindow.document;
            }

            if(iframeDoc != null){
                //We get here if the iframe document isn't null

                //Write HTML content to iframe
                //TODO: Investigate, talk of calling write not being recommended
                iframeDoc.write(content);
                iframeDoc.close();
            }else{
                //TODO: Check if it is possible to get here
            }
        }
    }

    /**
     * getTiddlyWikiContent returns the HTML content of the iframe widget
     *
     * @returns : HTML content of iframe (outerHTML)
     */
    public function getTiddlyWikiContent() : String{
        //Get iframe ExtJS object
        var iframe = getIframe();

        if(iframe != null){
            //Get iframe DOM object from ExtJS object
            //var iframe = element.getEl().dom;

            //Get iframe document
            var iframeDoc : Dynamic = null;

            if(iframe.contentDocument != null){
                iframeDoc = iframe.contentDocument;
            }else if(iframe.contentWindow.document != null){
                iframeDoc = iframe.contentWindow.document;
            }

            if(iframeDoc != null){
                //window.iframe.contentWindow
                return iframe.contentWindow.$tw.wiki.renderTiddler('text/plain', "$:/core/save/all");
                //Return the full HTML content of the iframe
                //return iframeDoc.documentElement.outerHTML;
            }else{
                //TODO: Check if it is possible to get here
            }
        }
        //TODO: is it possible to return null?
        return null;
    }

    public static function getQuickLaunchItems() : Array<Dynamic>{
        return [
        {
            iconCls :'x-btn-copy',
            html:'Notes',
            cls: 'quickLaunchButton',
            handler: function(){
                WorkspaceApplication.getApplication().getWorkspace().addObject(new TiddlyWiki(), true);
            },
            tooltip: {dismissDelay: 10000, text: 'Add notes to workspace'}
        }
        ];
    }

    override public function saveWait(cb){
        var obj = getEntity();

        obj.content = getTiddlyWikiContent();

        cb();
    }
}
