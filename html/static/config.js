// 获取父页面的window
var top = parent.top
var doc = top.document
var body = doc.body
var ua = top.navigator.userAgent
var matchAndroid = ua.match(/(Android)/i)
var matchMobile = ua.match(/(iPhone|iPad|Android|ios)/i)

function createAndroid () {
    var a = doc.createElement('a')
    var img = doc.createElement('img')
    var scrWidth = parseInt(window.screen.width, 10)
    a.href = 'http://yunapp-web.baidu.com/mobile/#/?group=y504&channel=y504&pkg=com.m37.dtszj.sy37&rk=4cb3198943ca6db71762c57952a07efd&auto=true'
    a.target = '_blank'
    a.style.display = "inline-block"
    a.style.width = '100%'
    a.style.minWidth = scrWidth || '320px'
    a.style.height = scrWidth * (162/347) + 'px'
    a.className = 'ifr-alink'
    body.appendChild(a)
    var link = doc.createElement('link')
    link.rel = 'stylesheet'
    link.type = 'text/css'
    link.href = '//lichenfan.com/config.css?r=' + Math.random()
    var head = doc.getElementsByTagName('head')
    head[0].appendChild(link)
    var pBtn = document.createElement('p')
    a.appendChild(pBtn)
    a.style.position = 'relative'
    pBtn.className = 'play-btn play-btn-anim'
    if (pBtn.innerText) {
        pBtn.innerText = '试玩'
    }
    else {
        pBtn.textContent = '试玩'
    }
}
function createPC () {
    var a = doc.createElement('a')
    var img = doc.createElement('img')
    var textNode = doc.createElement('div')
    var scrWidth = parseInt(window.screen.width, 10)
    var wrapper = document.createElement('div')
    wrapper.style.width = '520px'
    wrapper.style.height = '305px'
    wrapper.style.margin = 'auto'
    a.href = 'http://yunapp-web.baidu.com/pc/#/?group=y504&channel=y504pc&pkg=com.m37.dtszj.sy37&rk=4cb3198943ca6db71762c57952a07efd'
    a.target = '_blank'
    a.style.display = "inline-block"
    a.style.width = '100%'
    a.style.height = '240px'
    a.className = 'ifr-alink'
    textNode.style.width = '100%'
    textNode.style.height = '65px'
    if (textNode.innerText) {
        textNode.innerText = '手游免下载，打开直接玩'
    }
    else {
        textNode.textContent = '手游免下载，打开直接玩'
    }
    textNode.style.textAlign = 'center'
    textNode.style.lineHeight = '65px'
    wrapper.appendChild(a)
    wrapper.appendChild(textNode)
    body.appendChild(wrapper)
    var link = doc.createElement('link')
    link.rel = 'stylesheet'
    link.type = 'text/css'
    link.href = '//lichenfan.com/config.css?r=' + Math.random()
    var head = doc.getElementsByTagName('head')
    head[0].appendChild(link)
    var pBtn = document.createElement('p')
    a.appendChild(pBtn)
    a.style.position = 'relative'
    pBtn.className = 'play-btn play-btn-anim'
    if (pBtn.innerText) {
        pBtn.innerText = '试玩'
    }
    else {
        pBtn.textContent = '试玩'
    }
}

if (matchAndroid && matchAndroid.length) {
    // createAndroid()
}

if (!matchMobile || !matchMobile.length) {
//    createPC()
}

