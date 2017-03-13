window.CM = {
    init: function (c) {
        if (typeof c != "undefined") {
            for (var a in c) {
                this.config[a] = c[a]
            }
        }
        if ((this.config.restoreMenuState) && ($.cookie("cm-menu-toggled") == "true")) {
            $("body").addClass("cm-menu-toggled")
        }
        $("body").append('<div id="cm-menu-backdrop" class="visible-xs-block visible-sm-block"></div><div id="cm-submenu-popover" class="dropdown"><div data-toggle="dropdown"></div><div class="popover cm-popover right"><div class="arrow"></div><div class="popover-content"><ul></ul></div></div></div>');
        this.menu.init();
        this.search.init();
        this.navbars.init();
        this.breadcrumb.init();
        this.tabs.init();
        this.cmPopovers.init();
        this.fixHeight.init();
        if (typeof Touch != "undefined") {
            FastClick.attach(document.body);
            if (this.config.menuSwiper) {
                this.swiper.init(this)
            }
        }
        var b = this;
        $("[data-toggle='popover']").popover();
        $(".modal").on("show.bs.modal", function () {
            b.preventScroll.enable()
        });
        $(".modal").on("hidden.bs.modal", function () {
            b.preventScroll.disable()
        });
        $(window).load(function () {
            $("body").removeClass("cm-no-transition")
        })
    },
    config: {navbarHeight: 50, menuSwiper: true, menuSwiperIOS: true, restoreMenuState: true},
    fixHeight: {
        init: function () {
            $(window).load(this.process);
            $(window).resize(this.process)
        }, process: function () {
            $(".row.cm-fix-height .panel-body").css("min-height", "0px");
            $(".row.cm-fix-height").each(function () {
                var a = 0;
                $(this).find(".panel-body").each(function () {
                    var b = $(this).outerHeight();
                    if (b > a) {
                        a = b
                    }
                }).css("min-height", a + "px")
            })
        }
    },
    afterTransition: function (a) {
        setTimeout(a, 150)
    },
    breadcrumb: {
        init: function () {
            var b = $(".cm-navbar .breadcrumb");
            if (b.size()) {
                var d = b.parent();
                var a = function () {
                    b.removeClass("lonely");
                    b.find("li.active.ellipsis").remove();
                    b.find("li").removeAttr("style");
                    var e = 0;
                    var c = b.find("li").size() - 1;
                    while ((b.outerWidth() > (d.outerWidth() - 15)) && e < c) {
                        e++;
                        l = b.find("li:visible:first").hide()
                    }
                    var f = b.find("li:visible").size();
                    if ((f > 1) && e) {
                        b.prepend('<li class="active ellipsis">&#133;</li>')
                    } else {
                        if (f == 1) {
                            b.addClass("lonely");
                            b.find("li:visible:first").width(d.width())
                        }
                    }
                };
                $(window).load(a);
                $(window).resize(a)
            }
        }
    },
    tabs: {
        init: function () {
            var a = true;
            $(".cm-navbar .nav-tabs li").click(function () {
                var e = $(this);
                var d = e.parent(".nav-tabs");
                var g = d.scrollLeft() + e.position().left;
                var b = e.outerWidth();
                var h = d.width();
                var f = Math.max(g - ((h - b) / 2), 0);
                if (a) {
                    d.scrollLeft(f);
                    a = false
                } else {
                    d.animate({scrollLeft: f}, 100)
                }
            });
            $(".cm-navbar .nav-tabs").mousewheel(function (b) {
                var c = b.deltaY * b.deltaFactor * -1;
                $(this).scrollLeft($(this).scrollLeft() + c);
                return false
            });
            $(".cm-navbar .nav-tabs li.active").click()
        }
    },
    navbars: {
        init: function () {
            var a = this;
            var c = $(".cm-navbar-slideup");
            var b = $("#global");
            this.l = $(document).scrollTop();
            this.c = 0;
            if (c.size()) {
                $(document).scroll(function () {
                    if (!b.hasClass("prevent-scroll")) {
                        var e = $(document).scrollTop();
                        var d = Math.max(Math.min(a.c - e + a.l, 0), -CM.config.navbarHeight - 1);
                        if (e <= 0) {
                            c.css("transform", "translateY(0px)");
                            d = 0
                        } else {
                            c.css("transform", "translateY(" + d + "px)")
                        }
                        a.c = d;
                        a.l = e
                    }
                })
            }
        }
    },
    search: {
        init: function () {
            this.open = $("#cm-search-btn").hasClass("open");
            this.toggeling = false;
            var a = this;
            $("[data-toggle='cm-search']").click(function () {
                if (!a.open && !a.toggeling) {
                    a.open = true;
                    $("#cm-search input").focus()
                }
            });
            $("[data-toggle='cm-search']").mousedown(function () {
                a.toggeling = a.open
            });
            $("#cm-search input").focus(function () {
                $("#cm-search").addClass("open");
                $("#cm-search-btn").addClass("open");
                a.open = true
            });
            $("#cm-search input").blur(function () {
                $("#cm-search").removeClass("open");
                CM.afterTransition(function () {
                    $("#cm-search-btn").removeClass("open")
                });
                a.open = false
            })
        }
    },
    preventScroll: {
        s: -1, enable: function () {
            this.s = $(document).scrollTop();
            var b = $(".cm-footer");
            var a = $(window).height() + this.s - b.position().top - CM.config.navbarHeight;
            b.css("bottom", a + "px");
            $("#global").addClass("prevent-scroll").css("margin-top", "-" + this.s + "px")
        }, disable: function () {
            $("#global").removeAttr("style").removeClass("prevent-scroll");
            $(".cm-footer").removeAttr("style");
            if (this.s != -1) {
                $(document).scrollTop(this.s)
            }
        }
    },
    getState: function () {
        var a = {};
        a.mobile = ($("#cm-menu-backdrop").css("display") == "block");
        a.open = (a.mobile == $("body").hasClass("cm-menu-toggled"));
        return a
    },
    cmPopovers: {
        init: function () {
            $(".cm-navbar .popover").each(function () {
                var e = 10;
                var f = $(this).outerWidth();
                var i = $("body").outerWidth() - e;
                var g = (-f / 2) + (CM.config.navbarHeight / 2);
                var c = $(this).parent().offset().left + (CM.config.navbarHeight / 2);
                var a = c + f / 2;
                var j = c - f / 2;
                if (a > i) {
                    var h = a - i;
                    g -= h;
                    $(this).children(".arrow").css("left", f / 2 + h)
                } else {
                    if (j < e) {
                        var h = j - e;
                        g -= h;
                        $(this).children(".arrow").css("left", f / 2 + h)
                    }
                }
                $(this).css("left", g)
            })
        }
    },
    menu: {
        init: function () {
            var a = 0;
            var c = this;
            $(".cm-submenu ul").click(function (f) {
                //f.stopPropagation()
            });
            $("#cm-menu-scroller").scroll(this.hidePopover);
            $("[data-toggle='cm-menu']").click(this.toggle);
            $("#cm-menu-backdrop").click(function () {
                $("body").removeClass("cm-menu-toggled")
            });
            $("#cm-menu-scroller").mousewheel(function (h) {
                var i = CM.config.navbarHeight + 1;
                var g = h.deltaY * i + a;
                var f = -$(window).height() + i;
                $(".cm-menu-items > li, .cm-submenu.open > ul").each(function () {
                    f += $(this).height()
                });
                g = Math.max(Math.min(g, 0), -i * Math.ceil(f / i));
                g = Math.min(g, 0);
                $(".cm-menu-items").css("transform", "translateY(" + g + "px)");
                a = g;
                c.hidePopover();
                return false
            });
            $("#cm-menu a").click(function () {
                var f = CM.getState();
                var e = $(this).attr("href");
                if (e) {
                    if (f.mobile) {
                        $("body").removeClass("cm-menu-toggled");
                        $.cookie("cm-menu-toggled", false, {path: "/"})
                    }
                    if (!$(this).parents(".cm-submenu").size()) {
                        $(".cm-menu-items li").removeAttr("style");
                        $(".cm-submenu").removeClass("open")
                    }
                }
            });
            $(".cm-submenu").click(function (k, j, g) {
                var f = $(this);
                var i = CM.getState();
                if ((!i.mobile) && (!i.open)) {
                    c.setPopover(f);
                    return false
                }
                var h = f.hasClass("open");

                if (!h) {
                    $(".cm-submenu").removeClass("open");
                    $(".cm-menu-items li").removeAttr("style");

                    f.addClass("open");
                    f.nextAll().css("transform", "translateY(" + f.children("ul").height() + "px)")
                }
            });
            var d = CM.getState();
            if ((!d.mobile) && (!d.open)) {
                $(".cm-submenu.pre-open").removeClass("pre-open")
            } else {
                var b = $(".cm-submenu.pre-open");
                b.nextAll().css("transform", "translateY(" + b.children("ul").height() + "px)");
                b.addClass("open").removeClass("pre-open")
            }
        }, hidePopover: function () {
            $("#cm-submenu-popover").removeClass("open")
        }, setPopover: function (r) {
            var b = $("#cm-submenu-popover");
            var g = b.hasClass("open");
            var k = r.hasClass("popen");
            $(".cm-submenu").removeClass("popen");
            if (k && g) {
                this.hidePopover();
                return true
            }
            $("#cm-submenu-popover ul").html(r.find("ul").html());
            var e = 10;
            var i = $(window).height() - e;
            var q = $("#cm-submenu-popover").find(".arrow");
            var f = b.find(".popover").height();
            var j = r.position().top + CM.config.navbarHeight * 1.5 - f / 2;
            var n = j + f;
            q.show();
            if (n > i) {
                var c = n - i;
                j -= c;
                q.css("top", f / 2 + c)
            } else {
                if (j < e) {
                    var c = j - e;
                    j -= c;
                    q.css("top", f / 2 + c)
                } else {
                    q.css("top", "50%")
                }
            }
            if (q.position().top > f) {
                q.hide()
            }
            b.css("top", j);
            r.addClass("popen");
            if (!g) {
                $("#cm-submenu-popover [data-toggle='dropdown']").click()
            }
        }, toggle: function () {
            $(".container-fluid").addClass("animate");
            $("body").toggleClass("cm-menu-toggled");
            var a = CM.getState();
            if (!a.mobile) {
                $(".cm-submenu").removeClass("open");
                $(".cm-menu-items li").removeAttr("style");
                $(window).resize();
                $.cookie("cm-menu-toggled", (!a.open), {path: "/"})
            } else {
                $.cookie("cm-menu-toggled", false, {path: "/"});
                a.open ? CM.preventScroll.enable() : CM.preventScroll.disable()
            }
        }
    },
    swiper: {
        init: function () {
            var a = this;
            this.lock = false;
            this.menu = $("#cm-menu");
            this.mask = $("#cm-menu-backdrop");
            this.mwidth = this.menu.width();
            this.ios = navigator.vendor.indexOf("Apple") == 0 && /\sSafari\//.test(navigator.userAgent);
            if (this.ios && (!CM.config.menuSwiperIOS)) {
                return false
            }
            var b = $("[data-toggle='cm-menu']");
            $(b).bind("touchstart", function (c) {
                $(this).addClass("active");
                return false
            });
            $(b).bind("touchmove", function (c) {
                return false
            });
            $(b).bind("touchend", function (c) {
                $(this).removeClass("active");
                $(this).click();
                return false
            });
            $(b).bind("touchcancel", function (c) {
                $(this).removeClass("active");
                $(this).click();
                return false
            });
            $(document).bind("touchstart", function (c) {
                return a.start(c)
            });
            $(document).bind("touchmove", function (c) {
                return a.move(c)
            });
            $(document).bind("touchend", function (c) {
                return a.end(c)
            });
            $(document).bind("touchcancel", function (c) {
                return a.end(c)
            })
        }, start: function (c) {
            this.threshold = false;
            var d = c.originalEvent.changedTouches[0];
            var b = this.ios ? 10 : 0;
            var a = this.ios ? 90 : 50;
            this.lt = Date.now();
            this.lx = d.clientX;
            this.mobile = (this.mask.css("display") == "block");
            this.open = (this.mobile == $("body").hasClass("cm-menu-toggled"));
            this.xStart = d.clientX;
            this.yStart = d.clientY;
            this.lock = ((this.mobile && !this.open && ((this.xStart > a) || (this.xStart < b))) || (!this.mobile));
            if (this.mobile && this.open) {
                this.xStart = Math.min(this.xStart, this.mwidth)
            }
            if (!this.lock) {
                $("body").addClass("cm-no-transition")
            }
            return true
        }, move: function (d) {
            var f = d.originalEvent.changedTouches[0];
            var b = f.clientY - this.yStart;
            var c = Date.now();
            this.m = Math.abs(f.clientX - this.lx) / (c - this.lt);
            this.lx = f.clientX;
            this.lt = c;
            this.dx = f.clientX - this.xStart;
            if ((Math.abs(this.dx) < 10) && (!this.threshold)) {
                this.dx = 0
            } else {
                this.threshold = true
            }
            if ((Math.abs(b) > (Math.abs(this.dx) * 2)) || this.lock) {
                return true
            }
            if (this.mobile && this.open) {
                var a = Math.min(this.mwidth + this.dx, this.mwidth);
                this.translate(this.menu, a);
                this.mask.css("opacity", (a / this.mwidth) / 2)
            } else {
                if (this.mobile && !this.open) {
                    var a = Math.min(this.dx + this.xStart, this.mwidth);
                    this.translate(this.menu, a);
                    this.mask.css("visibility", "visible");
                    this.mask.css("opacity", (a / this.mwidth) / 2)
                }
            }
            return true
        }, end: function (a) {
            if (this.lock) {
                return true
            }
            $("body").removeClass("cm-no-transition");
            var b = Math.min(Math.max(this.m, 1), 3) * (this.open ? -1 : 1) * this.dx * 2;
            if (b > this.mwidth) {
                CM.menu.toggle()
            }
            this.menu.removeAttr("style");
            this.mask.removeAttr("style");
            return true
        }, translate: function (b, a) {
            b.css("transform", "translateX(" + a + "px)")
        }
    }
};
$(function () {
    CM.init({navbarHeight: 50, menuSwiper: true, menuSwiperIOS: true, restoreMenuState: true})
});
