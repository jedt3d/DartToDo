// Figma Plugin API source for the measured-reference review board.
// Font fallback is documented in font-limitation.md.
const page = await figma.getNodeByIdAsync('0:1');
await figma.setCurrentPageAsync(page);
await Promise.all(['Regular', 'Semi Bold'].map(style => figma.loadFontAsync({family: 'Inter', style})));
const sourceIds = {search:'5:2',list:'5:5',chevron:'5:8',repeat:'5:11',inbox:'5:14',suggestions:'5:17',group:'5:20',reminder:'5:23',note:'5:26',starFilled:'5:29',plus:'5:32',check:'5:35',close:'5:38',back:'5:41',more:'5:44',star:'5:47',sun:'5:50',delete:'5:53',attach:'5:56',calendar:'5:59',menu:'5:62',Search:'5:128',Composer:'5:133',nav:'5:73',navSelected:'5:79',task:'5:86',taskSelected:'5:95',taskCompleted:'5:104',completion:'5:65',completionDone:'5:67',action:'5:117',actionActive:'5:122'};
const varNames = {sidebar:'4:5',selected:'4:7',surface:'4:9',tasks:'4:11',text:'4:13',secondary:'4:15',accent:'4:17',important:'4:19',planned:'4:21',border:'4:23',divider:'4:25',composer:'4:27',selectedTask:'4:29',transparent:'4:31',space4:'4:33',space8:'4:35',space12:'4:37',space16:'4:39',space24:'4:41',space32:'4:43',radius4:'4:45',radius14:'4:47',sidebarWidth:'4:49',detailWidth:'4:51'};
const styleIds = {Body:'S:56dde255b515288d9d676bd616ae584d60173c03,',Metadata:'S:d3f3571961151d7ca5219e99ca359d9d4562d1d7,',Title:'S:3752b1586407aeeef0ed2c81337ec9d9b5a1d019,',Heading:'S:0013898253dd3ab38bc08964e9825aa3347e5121,'};
const [componentValues, variableValues] = await Promise.all([
  Promise.all(Object.values(sourceIds).map(id => figma.getNodeByIdAsync(id))),
  Promise.all(Object.values(varNames).map(id => figma.variables.getVariableByIdAsync('VariableID:' + id)))
]);
const components = Object.fromEntries(Object.keys(sourceIds).map((key,i) => [key,componentValues[i]]));
const variables = Object.fromEntries(Object.keys(varNames).map((key,i) => [key,variableValues[i]]));
if (page.findAllWithCriteria({types:['FRAME']}).some(n => n.name === 'DartToDo · Review')) throw new Error('Review board already exists; use stored IDs.');
function fill(node, name) { node.fills = [figma.variables.setBoundVariableForPaint({type:'SOLID',color:{r:0,g:0,b:0}},'color',variables[name])]; }
function bound(node, property, token) { node.setBoundVariable(property, variables[token]); }
function auto(parent,name,width,height,direction='VERTICAL',color) { const node=figma.createAutoLayout(direction);node.name=name;node.resize(width,height);node.primaryAxisSizingMode='FIXED';node.counterAxisSizingMode='FIXED';node.counterAxisAlignItems='MIN';node.fills=[];if(color)fill(node,color);if(parent)parent.appendChild(node);return node; }
function label(parent,name,value,style='Body',color='text',width) { const node=figma.createText();node.name=name;node.fontName={family:'Inter',style:style==='Heading'||style==='Title'?'Semi Bold':'Regular'};node.textStyleId=styleIds[style];node.characters=value;fill(node,color);parent.appendChild(node);if(width){node.textAutoResize='HEIGHT';node.resize(width,node.height);}return node; }
function icon(parent,name,size=20,color='secondary') { const instance=components[name].createInstance();instance.name='Icon/'+name;parent.appendChild(instance);instance.resize(size,size);for(const node of instance.findAllWithCriteria({types:['VECTOR']})){if(Array.isArray(node.fills))node.fills=node.fills.map(p=>p.type==='SOLID'?figma.variables.setBoundVariableForPaint(p,'color',variables[color]):p);}return instance; }
function space(parent,width) { const node=auto(parent,'Flexible space',width,20);node.layoutSizingVertical='FILL';return node; }
function divider(parent,width) { const node=figma.createRectangle();node.name='Divider';node.resize(width,1);fill(node,'divider');parent.appendChild(node);return node; }
function nav(parent,name,iconName,count,selected=false,color='secondary') { const node=components[selected?'navSelected':'nav'].createInstance();parent.appendChild(node);node.resize(parent.width,28);node.setProperties({'Label#5:0':name,'Count#5:3':count,'Icon#5:6':components[iconName].id});for(const v of node.findAllWithCriteria({types:['VECTOR']})){if(Array.isArray(v.fills))v.fills=v.fills.map(p=>p.type==='SOLID'?figma.variables.setBoundVariableForPaint(p,'color',variables[color]):p);}return node; }
function sidebar(parent,width,height,selected='Tasks') {
  const side=auto(parent,'Sidebar',width,height,'VERTICAL','sidebar');side.paddingTop=32;
  const profile=auto(side,'Local profile',width,40,'HORIZONTAL');profile.paddingLeft=12;profile.itemSpacing=8;profile.counterAxisAlignItems='CENTER';
  const avatar=auto(profile,'Local avatar',28,28,'HORIZONTAL','surface');avatar.cornerRadius=14;avatar.primaryAxisAlignItems='CENTER';avatar.counterAxisAlignItems='CENTER';label(avatar,'Initial','L','Body','accent');
  const identity=auto(profile,'Identity',width-60,38);label(identity,'User','Local user');label(identity,'Scope','Stored on this Mac','Metadata','secondary');
  const searchArea=auto(side,'Search area',width,42);searchArea.paddingLeft=12;searchArea.paddingTop=8;const search=components.Search.createInstance();searchArea.appendChild(search);search.resize(width-24,28);
  nav(side,'My Day','sun','',selected==='My Day');nav(side,'Important','star','1',false,'important');nav(side,'Planned','calendar','2',false,'planned');nav(side,'Tasks','inbox','3',selected==='Tasks','tasks');
  const separator=auto(side,'List separator',width,24);separator.paddingLeft=16;separator.paddingTop=12;divider(separator,width-32);nav(side,'Personal','list','2',false,'accent');nav(side,'Work','list','1',false,'accent');space(side,width);
  const bottom=auto(side,'New list and group',width,42,'HORIZONTAL');bottom.paddingLeft=16;bottom.paddingRight=16;bottom.itemSpacing=12;bottom.counterAxisAlignItems='CENTER';icon(bottom,'plus',20,'text');const l=label(bottom,'New List','New List');l.layoutSizingHorizontal='FILL';icon(bottom,'group',20,'text');return side;
}
function task(parent,title,metadata,state='task',important=false) { const node=components[state].createInstance();parent.appendChild(node);node.resize(parent.width,44);node.setProperties({'Title#5:9':title,'Metadata#5:13':metadata,'Star icon#5:17':components[important?'starFilled':'star'].id});return node; }
function listPane(parent,width,height,options={}) {
  const title=options.title||'Tasks',cw=width-32;const pane=auto(parent,title+' list',width,height,'VERTICAL','tasks');pane.paddingLeft=16;pane.paddingRight=16;pane.paddingBottom=16;if(options.phone)pane.paddingTop=40;
  const heading=auto(pane,'List header',cw,options.phone?88:82);heading.paddingTop=options.phone?20:32;const row=auto(heading,'Header actions',cw,30,'HORIZONTAL');row.counterAxisAlignItems='CENTER';row.itemSpacing=8;if(options.phone)icon(row,'back',20,'surface');const titleNode=label(row,'List title',title,'Heading','surface');titleNode.layoutSizingHorizontal='FILL';if(title==='My Day')icon(row,'suggestions',22,'surface');const button=auto(row,'List options',42,28,'HORIZONTAL','composer');button.cornerRadius=4;button.primaryAxisAlignItems='CENTER';button.counterAxisAlignItems='CENTER';icon(button,'more',20,'surface');if(options.myDay)label(heading,'Date','Tuesday, 17 November','Body','surface');
  const tasks=auto(pane,'Task items',cw,options.empty?80:212);tasks.itemSpacing=2;if(!options.empty){task(tasks,'Plan the week','Note · 1 of 3','taskSelected',true);task(tasks,'Pick up groceries','Today · Personal');task(tasks,'Book a dentist appointment','Tomorrow');const completed=auto(tasks,'Completed heading',cw,28,'HORIZONTAL');completed.counterAxisAlignItems='CENTER';const badge=auto(completed,'Completed badge',96,20,'HORIZONTAL','composer');badge.cornerRadius=4;badge.paddingLeft=6;label(badge,'Completed','Completed','Metadata','surface');task(tasks,'Read a chapter','Personal','taskCompleted');}
  space(pane,cw);const composer=components.Composer.createInstance();pane.appendChild(composer);composer.resize(cw,42);return pane;
}
function action(parent,title,name,active=false) { const node=components[active?'actionActive':'action'].createInstance();parent.appendChild(node);node.resize(parent.width-parent.paddingLeft-parent.paddingRight,44);node.setProperties({'Label#5:21':title,'Icon#5:24':components[name].id});return node; }
function detail(parent,width,height,phone=false) {
  const d=auto(parent,'Task details',width,height,'VERTICAL','surface');d.paddingLeft=16;d.paddingRight=16;d.paddingTop=phone?52:32;d.paddingBottom=16;const cw=width-32;
  if(phone){const top=auto(d,'Back to Tasks',cw,32,'HORIZONTAL');top.itemSpacing=4;icon(top,'back',20,'accent');label(top,'Back','Tasks','Body','accent');}
  const title=auto(d,'Task title',cw,34,'HORIZONTAL');title.itemSpacing=12;title.counterAxisAlignItems='CENTER';title.appendChild(components.completion.createInstance());const t=label(title,'Task title','Plan the week','Title','text',cw-76);t.layoutSizingHorizontal='FILL';icon(title,'starFilled',20,'accent');
  for(const [value,complete]of[['Review the calendar',true],['Choose three priorities',false]]){const row=auto(d,'Step',cw,30,'HORIZONTAL');row.itemSpacing=12;row.counterAxisAlignItems='CENTER';row.appendChild(components[complete?'completionDone':'completion'].createInstance());const text=label(row,'Step title',value);if(complete)text.textDecoration='STRIKETHROUGH';}
  action(d,'Add Step','plus',true);divider(d,cw);action(d,'Add to My Day','sun');divider(d,cw);action(d,'Remind Me','reminder');action(d,'Add Due Date','calendar');action(d,'Repeat','repeat');divider(d,cw);action(d,'Add File','attach');divider(d,cw);
  const notes=auto(d,'Notes',cw,88);notes.paddingTop=12;label(notes,'Note','Keep the plan realistic. Leave room for a break.','Body','text',cw);space(d,cw);divider(d,cw);
  const footer=auto(d,'Task footer',cw,32,'HORIZONTAL');footer.itemSpacing=8;footer.counterAxisAlignItems='CENTER';if(!phone)icon(footer,'chevron',16);const created=label(footer,'Created','Created Tuesday, 17 November','Metadata','secondary',cw-44);created.layoutSizingHorizontal='FILL';icon(footer,'delete',18);return d;
}
function figure(parent,name,width,height) { const figure=auto(parent,name+' figure',width,height+32);label(figure,'Caption',name,'Body','secondary');const screen=auto(figure,name,width,height,'HORIZONTAL');screen.cornerRadius=12;screen.clipsContent=true;return screen; }
const board=auto(page,'DartToDo · Review',2240,1920,'VERTICAL','surface');board.x=100;board.y=100;board.paddingLeft=16;board.paddingRight=16;board.paddingTop=16;board.paddingBottom=16;board.itemSpacing=24;
const intro=auto(board,'Design scope',2208,64);label(intro,'Title','DartToDo · Local by design','Heading');label(intro,'Subtitle','Editable native-reference reconstruction · macOS, iPad and iPhone · 17 November 2026','Body','secondary');
const row1=auto(board,'Desktop states',2208,752,'HORIZONTAL');row1.itemSpacing=24;
const desktop=figure(row1,'macOS · Tasks and details',1100,720);sidebar(desktop,244,720);listPane(desktop,536,720);detail(desktop,320,720);
const myDay=figure(row1,'macOS · My Day',1084,720);sidebar(myDay,244,720,'My Day');const myDayBackground=listPane(myDay,840,720,{title:'My Day',empty:true,myDay:true});
const row2=auto(board,'Adaptive tablet and phone states',2208,876,'HORIZONTAL');row2.itemSpacing=24;
const ipad=figure(row2,'iPad · Tasks',1024,768);sidebar(ipad,244,768);listPane(ipad,780,768);
const iphone=figure(row2,'iPhone · Tasks',390,844);listPane(iphone,390,844,{phone:true});
const iphoneDetail=figure(row2,'iPhone · Task details',390,844);detail(iphoneDetail,390,844,true);
const scope=auto(board,'Scope and fidelity notes',2208,100);label(scope,'Local-only','LOCAL ONLY · One user; PostgreSQL on this Mac. No Microsoft sign-in, sharing, assigned work or flagged email.','Body','secondary',2180);label(scope,'Evidence limit','Native macOS measurements guide layout. Mobile views are adaptive specifications. Figma uses Inter because SF Pro is listed but reports missing fonts; native Flutter retains Apple system type. No pixel-parity claim.','Body','secondary',2180);
const frames={review:board.id,desktop:desktop.id,myDay:myDay.id,myDayBackground:myDayBackground.id,ipad:ipad.id,iphone:iphone.id,iphoneDetail:iphoneDetail.id};
const all=[board,...board.findAll(()=>true)],counts={};for(const n of all)counts[n.type]=(counts[n.type]||0)+1;
return {createdNodeIds:all.map(n=>n.id),frames,counts,bounds:Object.fromEntries(Object.entries(frames).map(([name,id])=>{const n=all.find(x=>x.id===id);return[name,{x:n.x,y:n.y,width:n.width,height:n.height}]})),fonts:[...new Set(board.findAllWithCriteria({types:['TEXT']}).map(t=>t.fontName.family))],imageFilledNodes:[]};
