(()=>{'use strict';
const $=id=>document.getElementById(id),video=$('liveVideo'),embed=$('embedPlayer'),status=$('liveStatus'),empty=$('watchEmpty'),retry=$('retry');let hls=null,db=null,busy=false,current=null,version=0;
$('year').textContent=new Date().getFullYear();
function setStatus(text,state='idle'){status.textContent=text;status.dataset.state=state}
function clearPlayer(){video.hidden=true;if(hls){hls.destroy();hls=null}video.pause();video.removeAttribute('src');video.load();video.hidden=true;embed.replaceChildren();embed.hidden=true;$('goLive').hidden=true;$('fullscreen').hidden=true}
function unavailable(message,state='idle'){clearPlayer();empty.hidden=false;$('watchMessage').textContent=message;retry.hidden=false;setStatus(state==='error'?'Emissão indisponível':'Fora de emissão',state)}
function ready(){empty.hidden=true;retry.hidden=true;$('fullscreen').hidden=false;setStatus('Emissão disponível')}
function fail(){current=null;unavailable('Não foi possível reproduzir a emissão. Tenta actualizar o leitor.','error')}
video.addEventListener('playing',()=>{if(!video.hidden)setStatus('Em directo','playing')});
video.addEventListener('waiting',()=>{if(!video.hidden)setStatus('A carregar…')});
video.addEventListener('pause',()=>{if(!video.hidden&&video.readyState>0)setStatus('Emissão em pausa')});
video.addEventListener('error',()=>{if(!video.hidden)fail()});
function source(o){let u;try{u=new URL(o.video_url);if(u.protocol!=='https:'&&!(u.protocol==='http:'&&location.protocol==='http:'))throw Error()}catch{return fail()}
clearPlayer();const host=u.hostname.replace(/^www\./,'');let link=null;
if(host==='youtu.be'||['youtube.com','m.youtube.com'].includes(host)){const id=host==='youtu.be'?u.pathname.slice(1):u.searchParams.get('v')||u.pathname.match(/\/(?:live|embed|shorts)\/([\w-]+)/)?.[1];if(id&&/^[\w-]{11}$/.test(id))link='https://www.youtube-nocookie.com/embed/'+id}
if(['vimeo.com','player.vimeo.com'].includes(host)){const id=u.pathname.match(/\/(\d+)/)?.[1];if(id)link='https://player.vimeo.com/video/'+id}
if(link){const frame=document.createElement('iframe');frame.src=link;frame.title='Emissão em directo da BTV';frame.allow='autoplay; fullscreen; picture-in-picture; encrypted-media';frame.allowFullscreen=true;embed.append(frame);embed.hidden=false;ready();return}
video.hidden=false;
if(/\.m3u8$/i.test(u.pathname)){if(video.canPlayType('application/vnd.apple.mpegurl'))video.src=u.href;else if(window.Hls&&Hls.isSupported()){hls=new Hls();hls.on(Hls.Events.ERROR,(_e,d)=>{if(d.fatal)fail()});hls.loadSource(u.href);hls.attachMedia(video)}else return fail();$('goLive').hidden=false}
else if(/\.(mp4|webm|ogg)$/i.test(u.pathname))video.src=u.href;else return fail();ready();
}
async function refresh(force=false){if(busy)return;busy=true;try{const cfg=window.BTV_CONFIG;if(!cfg?.url||!cfg?.anonKey||!window.supabase){current=null;return unavailable('A emissão online ainda não está disponível. Volta mais tarde.')}
if(!db)db=window.supabase.createClient(cfg.url,cfg.anonKey);
const r=await db.from('btv_contents').select('id,title,description,video_url,thumbnail_url').eq('kind','live').eq('status','published').order('sort_order').order('created_at',{ascending:false}).limit(1).maybeSingle();if(r.error)throw r.error;
const o=r.data;if(!o?.video_url){current=null;$('streamTitle').textContent='Emissão BTV';$('streamDescription').textContent='A Casa da Cultura, onde estiveres.';return unavailable('De momento, não existe uma transmissão disponível.')}
$('streamTitle').textContent=o.title||'Emissão BTV';$('streamDescription').textContent=o.description||'A Casa da Cultura, onde estiveres.';const key=o.id+'|'+o.video_url;if(force||key!==current){current=key;source(o)}
}catch(e){console.error(e);if(!current)unavailable('Não foi possível verificar a emissão. Tenta novamente.','error')}finally{busy=false}}
retry.onclick=()=>refresh(true);$('reloadStream').onclick=()=>refresh(true);
$('goLive').onclick=()=>{try{if(video.seekable.length){video.currentTime=Math.max(video.seekable.start(video.seekable.length-1),video.seekable.end(video.seekable.length-1)-1);video.play().catch(()=>{})}}catch{}};
$('fullscreen').onclick=async()=>{try{const p=$('watchPlayer');if(p.requestFullscreen)await p.requestFullscreen();else if(!video.hidden&&video.webkitEnterFullscreen)video.webkitEnterFullscreen();else $('watchFeedback').textContent='Utiliza o botão de ecrã inteiro do leitor.'}catch{$('watchFeedback').textContent='Utiliza o botão de ecrã inteiro do leitor.'}};
$('share').onclick=async()=>{try{if(navigator.share){await navigator.share({title:'BTV em directo',url:location.href});return}if(navigator.clipboard){await navigator.clipboard.writeText(location.href);$('watchFeedback').textContent='Ligação copiada.';return}}catch(e){if(e.name==='AbortError')return}$('watchFeedback').textContent=location.href};
refresh();setInterval(()=>{if(!document.hidden)refresh()},30000);document.addEventListener('visibilitychange',()=>{if(!document.hidden)refresh()});window.addEventListener('online',()=>refresh());
})();