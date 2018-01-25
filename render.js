try {
	$('html').addClass("hidden")
	let doc_ready = new Promise(resolve => $(resolve))

	var scriptStarted = Date.now()
	var domReady = scriptStarted
	$(document).ready(() => domReady=Date.now())
	var domLoaded = scriptStarted
	$(window).on('load', () => domLoaded=Date.now())

	let loadCss = new Promise(resolve => doc_ready.then(() => {
		var url=new URL(window.location)
		var params=new URLSearchParams(url.search)

		if (!params.has('css')) return resolve()
		else var css=params.get('css')

		if (/^((https?:)?\/\/)?\/?([\w\d%-\.~_!\$&'\(\)\*\+,;=:]+\/?)*(#\w*)?(\?[\w\d%-\.~_!\$&'\(\)\*\+,;=:]*)?$/.test(css)) {
			$("<link>")
				.prop('rel', "stylesheet")
				.prop('type', "text/css")
				.prop('href', css)
				.appendTo('head')
				.on('load', resolve)
		} else {
			$("<style>")
				.prop('type', "text/css")
				.html(css)
				.appendTo('head')
				.on('load', resolve)
		}
	}))

	let correctAsideEffects = loadCss.finally(() => {
		var maxTop=-Infinity
		$('aside').offset(function(i, o){
			return {
				top: maxTop=Math.max(o.top, maxTop+20), //TODO Don't hardcode 1em+1px
				left: o.left
			}
		})
	})

	let nextSideEntityIndicatorDiv = doc_ready.then(() => {
		$("<div>")
			.css({
				position: "fixed",
				bottom: 0,
				right: 0,
				background: "white",
				cursor: "pointer"
			})
			.prop('id', "nextsideentityindicator")
			.click(function(e){
				$('html, body').animate({
					scrollTop: $(nextSideEntity).offset().top-$(window).height()+$(nextSideEntity).outerHeight()
				}, 800)
				e.preventDefault()
			})
			.appendTo('body')
	})

	var nextSideEntityCalcInProgress=false
	var nextSideEntity=undefined
	let nextSideEntityIndicatorUpdater = nextSideEntityIndicatorDiv.then(() => {
		return async (allowAsync=false) => {
			return await new Promise((resolve, reject) => {
				if (nextSideEntityCalcInProgress && !allowAsync) throw Error("Async call. Maybe too fast scroll?")
				else nextSideEntityCalcInProgress=true

				var after=$('#nextsideentityindicator').offset().top
				var notbefore=after+$('#nextsideentityindicator').outerHeight()
				var cnt=0
				var result=undefined
				$('p, aside').each(function(i, e){
					if ($(e).offset().top+$(e).outerHeight()<after) return true
					if (e.tagName=="ASIDE") {
						if ($(e).offset().top<=notbefore) return false
						result=e
						return false
					} else {
						cnt++
					}
				})
				$('#nextsideentityindicator')
					.text(result?"Next side entry in "+cnt:"")
					.css('background', "white")
				nextSideEntity=result

				nextSideEntityCalcInProgress=false
			})
		}
	})

	let registerNextSideEntityIndicator = nextSideEntityIndicatorUpdater.then(f => {
		$(document).scroll(event => {
			f().catch(() => {
				$("#nextsideentityindicator").css('background-color', "grey")
				console.log("Too fast scroll")
			})
			event.preventDefault() //assuming it will be successfull
		})
	})

	let nextSideEntityIndicatorPreload = Promise.all([nextSideEntityIndicatorUpdater, correctAsideEffects]).then(values => {
		let f = values[0]
		f(true)
	})

	let showDocument = Promise.all([
		loadCss.catch(),
		correctAsideEffects.catch(),
		nextSideEntityIndicatorDiv.catch(),
		nextSideEntityIndicatorPreload.catch()
	]).finally(() => {
		if (Date.now()-scriptStarted < 1000) $('html').removeClass("hideable")
	}).finally(() => {
		$('html').removeClass("hidden")
	})
} catch(e) {
	$('html').removeClass("hidden")
	throw e
}
