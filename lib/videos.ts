import videosJson from "@/data/videos.json";
import type {MusicVideo} from "@/types/music-video";
const palette=[["#7b1e22","#160809"],["#1f5b44","#07120e"],["#3b4f7c","#0a0d17"],["#7a5d2b","#171007"],["#5c3a66","#120914"],["#224b59","#071014"]];
const slug=(v:MusicVideo)=>v.slug||`${v.artist}-${v.title}`.normalize("NFKD").replace(/[\u0300-\u036f]/g,"").toLowerCase().replace(/&/g," and ").replace(/[^a-z0-9\u3040-\u30ff\u3400-\u9fff]+/g,"-").replace(/^-+|-+$/g,"");
export const decorateVideo=(v:MusicVideo):MusicVideo=>{const seed=[...`${v.artist}${v.title}`].reduce((s,c)=>s+c.charCodeAt(0),0),[p,s]=palette[seed%palette.length];return{...v,slug:slug(v),primaryColor:v.primaryColor||p,secondaryColor:v.secondaryColor||s}};
export const videos:MusicVideo[]=(videosJson as MusicVideo[]).map(decorateVideo);
export const getVideoBySlug=(slug:string)=>videos.find(v=>v.slug===slug);
