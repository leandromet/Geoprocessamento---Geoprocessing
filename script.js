(function(exports, global) {
    global["app"] = exports;
    (function($) {
        var modulo = angular.module("SICAR", [ "ngRoute", "acessarServico", "mascaras", "ui.bootstrap", "ngAnimate", "ngSanitize", "angular-clipboard", "ngMask" ]);
        modulo.config([ "$routeProvider", "$locationProvider", function($routeProvider, $locationProvider) {
            $routeProvider.when("/sobre", {
                templateUrl: "/sections/sobre.html",
                controller: "SobreCtrl"
            }).when("/contatos", {
                templateUrl: "/sections/contatos.html",
                controller: "ContatosCtrl"
            }).when("/busca", {
                templateUrl: "/sections/busca.html",
                controller: "BuscaCtrl"
            }).when("/baixar", {
                templateUrl: "/sections/baixar.html",
                controller: "BaixarCtrl"
            }).when("/enviar", {
                templateUrl: "/sections/enviar.html",
                controller: "EnviarCtrl"
            }).when("/retificar", {
                templateUrl: "/sections/retificar.html"
            }).when("/consultar", {
                templateUrl: "/sections/consultar.html",
                controller: "ConsultarCtrl"
            }).when("/consultar/:codigo", {
                templateUrl: "/sections/consultar.html",
                controller: "ConsultarCtrl"
            }).when("/suporte", {
                templateUrl: "/sections/suporte.html",
                controller: "SuporteCtrl"
            }).when("/suporte/:conteudoAtual", {
                templateUrl: "/sections/suporte.html",
                controller: "SuporteCtrl"
            }).when("/central/acesso", {
                templateUrl: "/sections/central/acesso.html",
                controller: "CentralAcessoCtrl"
            }).when("/central/pessoaFisica", {
                templateUrl: "/sections/central/pessoaFisica.html",
                controller: "CentralPessoaFisicaCtrl"
            }).when("/central/formulario", {
                templateUrl: "/sections/central/formulario.html",
                controller: "CentralFormularioCtrl"
            }).when("/central/pessoaJuridica", {
                templateUrl: "/sections/central/pessoaJuridica.html",
                controller: "CentralPessoaJuridicaCtrl"
            }).when("/recuperarSenha", {
                templateUrl: "/sections/recuperarSenha.html",
                controller: "CentralCtrl"
            }).when("/", {
                templateUrl: "/sections/inicial.html",
                controller: "HomeCtrl"
            }).otherwise({
                redirectTo: "/"
            });
        } ]).controller("SICARCtrl", [ "$scope", "$rootScope", "$location", "loginService", "config", function($scope, $rootScope, $location, loginService, config) {
            if ($location.path() !== "/central/formulario") {
                loginService.isLogged(function(data) {
                    if (data.status === "s") {
                        window.location.href = config.BASE_URL + "/intranet";
                    }
                });
            }
            $scope.$on("$routeChangeStart", function() {
                $("#redes-sociais-footer").addClass("exibir-redes-sociais");
            });
            $scope.removeContainer = function() {
                setTimeout(function() {
                    $("#view").removeClass("container main-container");
                }, 0);
            };
            $rootScope.alert = function(mensagem, tipo, titulo) {
                $scope.obj = {
                    mensagem: mensagem,
                    tituloClass: tipo || "bg-danger",
                    titulo: titulo || "AtenÃ§Ã£o"
                };
                $("#modalAlert").modal();
            };
            $scope.setarAbaAtual = function(tela) {
                $rootScope.abaAtual = tela;
            };
            if (isOldIE()) {
                $("#modalOldIE").modal();
            }
            $("#myNavbar a").click(function() {
                $("#myNavbar").collapse("hide");
                $("#botaoMenuPrincipal").toggleClass("active");
            });
            $("#botaoMenuPrincipal").click(function() {
                $("#botaoMenuPrincipal").toggleClass("active");
            });
        } ]);
        function getInternetExplorerVersion() {
            var rv = -1;
            if (navigator.appName == "Microsoft Internet Explorer") {
                var ua = navigator.userAgent;
                var re = new RegExp("MSIE ([0-9]{1,}[.0-9]{0,})");
                if (re.exec(ua) !== null) {
                    rv = parseFloat(RegExp.$1);
                }
            }
            return rv;
        }
        function isOldIE() {
            var ver = getInternetExplorerVersion();
            if (ver > -1) {
                return ver <= 8;
            }
            return false;
        }
    })(jQuery);
    (function() {
        angular.module("SICAR").factory("$MD5", function() {
            return function(string) {
                function RotateLeft(lValue, iShiftBits) {
                    return lValue << iShiftBits | lValue >>> 32 - iShiftBits;
                }
                function AddUnsigned(lX, lY) {
                    var lX4, lY4, lX8, lY8, lResult;
                    lX8 = lX & 2147483648;
                    lY8 = lY & 2147483648;
                    lX4 = lX & 1073741824;
                    lY4 = lY & 1073741824;
                    lResult = (lX & 1073741823) + (lY & 1073741823);
                    if (lX4 & lY4) {
                        return lResult ^ 2147483648 ^ lX8 ^ lY8;
                    }
                    if (lX4 | lY4) {
                        if (lResult & 1073741824) {
                            return lResult ^ 3221225472 ^ lX8 ^ lY8;
                        } else {
                            return lResult ^ 1073741824 ^ lX8 ^ lY8;
                        }
                    } else {
                        return lResult ^ lX8 ^ lY8;
                    }
                }
                function F(x, y, z) {
                    return x & y | ~x & z;
                }
                function G(x, y, z) {
                    return x & z | y & ~z;
                }
                function H(x, y, z) {
                    return x ^ y ^ z;
                }
                function I(x, y, z) {
                    return y ^ (x | ~z);
                }
                function FF(a, b, c, d, x, s, ac) {
                    a = AddUnsigned(a, AddUnsigned(AddUnsigned(F(b, c, d), x), ac));
                    return AddUnsigned(RotateLeft(a, s), b);
                }
                function GG(a, b, c, d, x, s, ac) {
                    a = AddUnsigned(a, AddUnsigned(AddUnsigned(G(b, c, d), x), ac));
                    return AddUnsigned(RotateLeft(a, s), b);
                }
                function HH(a, b, c, d, x, s, ac) {
                    a = AddUnsigned(a, AddUnsigned(AddUnsigned(H(b, c, d), x), ac));
                    return AddUnsigned(RotateLeft(a, s), b);
                }
                function II(a, b, c, d, x, s, ac) {
                    a = AddUnsigned(a, AddUnsigned(AddUnsigned(I(b, c, d), x), ac));
                    return AddUnsigned(RotateLeft(a, s), b);
                }
                function ConvertToWordArray(string) {
                    var lWordCount;
                    var lMessageLength = string.length;
                    var lNumberOfWords_temp1 = lMessageLength + 8;
                    var lNumberOfWords_temp2 = (lNumberOfWords_temp1 - lNumberOfWords_temp1 % 64) / 64;
                    var lNumberOfWords = (lNumberOfWords_temp2 + 1) * 16;
                    var lWordArray = Array(lNumberOfWords - 1);
                    var lBytePosition = 0;
                    var lByteCount = 0;
                    while (lByteCount < lMessageLength) {
                        lWordCount = (lByteCount - lByteCount % 4) / 4;
                        lBytePosition = lByteCount % 4 * 8;
                        lWordArray[lWordCount] = lWordArray[lWordCount] | string.charCodeAt(lByteCount) << lBytePosition;
                        lByteCount++;
                    }
                    lWordCount = (lByteCount - lByteCount % 4) / 4;
                    lBytePosition = lByteCount % 4 * 8;
                    lWordArray[lWordCount] = lWordArray[lWordCount] | 128 << lBytePosition;
                    lWordArray[lNumberOfWords - 2] = lMessageLength << 3;
                    lWordArray[lNumberOfWords - 1] = lMessageLength >>> 29;
                    return lWordArray;
                }
                function WordToHex(lValue) {
                    var WordToHexValue = "", WordToHexValue_temp = "", lByte, lCount;
                    for (lCount = 0; lCount <= 3; lCount++) {
                        lByte = lValue >>> lCount * 8 & 255;
                        WordToHexValue_temp = "0" + lByte.toString(16);
                        WordToHexValue = WordToHexValue + WordToHexValue_temp.substr(WordToHexValue_temp.length - 2, 2);
                    }
                    return WordToHexValue;
                }
                function Utf8Encode(string) {
                    string = string.replace(/\r\n/g, "\n");
                    var utftext = "";
                    for (var n = 0; n < string.length; n++) {
                        var c = string.charCodeAt(n);
                        if (c < 128) {
                            utftext += String.fromCharCode(c);
                        } else if (c > 127 && c < 2048) {
                            utftext += String.fromCharCode(c >> 6 | 192);
                            utftext += String.fromCharCode(c & 63 | 128);
                        } else {
                            utftext += String.fromCharCode(c >> 12 | 224);
                            utftext += String.fromCharCode(c >> 6 & 63 | 128);
                            utftext += String.fromCharCode(c & 63 | 128);
                        }
                    }
                    return utftext;
                }
                var x = Array();
                var k, AA, BB, CC, DD, a, b, c, d;
                var S11 = 7, S12 = 12, S13 = 17, S14 = 22;
                var S21 = 5, S22 = 9, S23 = 14, S24 = 20;
                var S31 = 4, S32 = 11, S33 = 16, S34 = 23;
                var S41 = 6, S42 = 10, S43 = 15, S44 = 21;
                string = Utf8Encode(string);
                x = ConvertToWordArray(string);
                a = 1732584193;
                b = 4023233417;
                c = 2562383102;
                d = 271733878;
                for (k = 0; k < x.length; k += 16) {
                    AA = a;
                    BB = b;
                    CC = c;
                    DD = d;
                    a = FF(a, b, c, d, x[k + 0], S11, 3614090360);
                    d = FF(d, a, b, c, x[k + 1], S12, 3905402710);
                    c = FF(c, d, a, b, x[k + 2], S13, 606105819);
                    b = FF(b, c, d, a, x[k + 3], S14, 3250441966);
                    a = FF(a, b, c, d, x[k + 4], S11, 4118548399);
                    d = FF(d, a, b, c, x[k + 5], S12, 1200080426);
                    c = FF(c, d, a, b, x[k + 6], S13, 2821735955);
                    b = FF(b, c, d, a, x[k + 7], S14, 4249261313);
                    a = FF(a, b, c, d, x[k + 8], S11, 1770035416);
                    d = FF(d, a, b, c, x[k + 9], S12, 2336552879);
                    c = FF(c, d, a, b, x[k + 10], S13, 4294925233);
                    b = FF(b, c, d, a, x[k + 11], S14, 2304563134);
                    a = FF(a, b, c, d, x[k + 12], S11, 1804603682);
                    d = FF(d, a, b, c, x[k + 13], S12, 4254626195);
                    c = FF(c, d, a, b, x[k + 14], S13, 2792965006);
                    b = FF(b, c, d, a, x[k + 15], S14, 1236535329);
                    a = GG(a, b, c, d, x[k + 1], S21, 4129170786);
                    d = GG(d, a, b, c, x[k + 6], S22, 3225465664);
                    c = GG(c, d, a, b, x[k + 11], S23, 643717713);
                    b = GG(b, c, d, a, x[k + 0], S24, 3921069994);
                    a = GG(a, b, c, d, x[k + 5], S21, 3593408605);
                    d = GG(d, a, b, c, x[k + 10], S22, 38016083);
                    c = GG(c, d, a, b, x[k + 15], S23, 3634488961);
                    b = GG(b, c, d, a, x[k + 4], S24, 3889429448);
                    a = GG(a, b, c, d, x[k + 9], S21, 568446438);
                    d = GG(d, a, b, c, x[k + 14], S22, 3275163606);
                    c = GG(c, d, a, b, x[k + 3], S23, 4107603335);
                    b = GG(b, c, d, a, x[k + 8], S24, 1163531501);
                    a = GG(a, b, c, d, x[k + 13], S21, 2850285829);
                    d = GG(d, a, b, c, x[k + 2], S22, 4243563512);
                    c = GG(c, d, a, b, x[k + 7], S23, 1735328473);
                    b = GG(b, c, d, a, x[k + 12], S24, 2368359562);
                    a = HH(a, b, c, d, x[k + 5], S31, 4294588738);
                    d = HH(d, a, b, c, x[k + 8], S32, 2272392833);
                    c = HH(c, d, a, b, x[k + 11], S33, 1839030562);
                    b = HH(b, c, d, a, x[k + 14], S34, 4259657740);
                    a = HH(a, b, c, d, x[k + 1], S31, 2763975236);
                    d = HH(d, a, b, c, x[k + 4], S32, 1272893353);
                    c = HH(c, d, a, b, x[k + 7], S33, 4139469664);
                    b = HH(b, c, d, a, x[k + 10], S34, 3200236656);
                    a = HH(a, b, c, d, x[k + 13], S31, 681279174);
                    d = HH(d, a, b, c, x[k + 0], S32, 3936430074);
                    c = HH(c, d, a, b, x[k + 3], S33, 3572445317);
                    b = HH(b, c, d, a, x[k + 6], S34, 76029189);
                    a = HH(a, b, c, d, x[k + 9], S31, 3654602809);
                    d = HH(d, a, b, c, x[k + 12], S32, 3873151461);
                    c = HH(c, d, a, b, x[k + 15], S33, 530742520);
                    b = HH(b, c, d, a, x[k + 2], S34, 3299628645);
                    a = II(a, b, c, d, x[k + 0], S41, 4096336452);
                    d = II(d, a, b, c, x[k + 7], S42, 1126891415);
                    c = II(c, d, a, b, x[k + 14], S43, 2878612391);
                    b = II(b, c, d, a, x[k + 5], S44, 4237533241);
                    a = II(a, b, c, d, x[k + 12], S41, 1700485571);
                    d = II(d, a, b, c, x[k + 3], S42, 2399980690);
                    c = II(c, d, a, b, x[k + 10], S43, 4293915773);
                    b = II(b, c, d, a, x[k + 1], S44, 2240044497);
                    a = II(a, b, c, d, x[k + 8], S41, 1873313359);
                    d = II(d, a, b, c, x[k + 15], S42, 4264355552);
                    c = II(c, d, a, b, x[k + 6], S43, 2734768916);
                    b = II(b, c, d, a, x[k + 13], S44, 1309151649);
                    a = II(a, b, c, d, x[k + 4], S41, 4149444226);
                    d = II(d, a, b, c, x[k + 11], S42, 3174756917);
                    c = II(c, d, a, b, x[k + 2], S43, 718787259);
                    b = II(b, c, d, a, x[k + 9], S44, 3951481745);
                    a = AddUnsigned(a, AA);
                    b = AddUnsigned(b, BB);
                    c = AddUnsigned(c, CC);
                    d = AddUnsigned(d, DD);
                }
                var temp = WordToHex(a) + WordToHex(b) + WordToHex(c) + WordToHex(d);
                var saida = temp[0] + temp[1] + "-" + temp[2] + temp[3] + "-" + temp[4] + temp[5] + "-" + temp[6] + temp[7] + "-" + temp[8] + temp[9] + "-" + temp[10] + temp[11] + "-" + temp[12] + temp[13] + "-" + temp[14] + temp[15] + "-" + temp[16] + temp[17] + "-" + temp[18] + temp[19] + "-" + temp[20] + temp[21] + "-" + temp[22] + temp[23] + "-" + temp[24] + temp[25] + "-" + temp[26] + temp[27] + "-" + temp[28] + temp[29] + "-" + temp[30] + temp[31];
                return saida.toUpperCase();
            };
        });
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("CentralCtrl", [ "$rootScope", "$scope", "$http", "$MD5", "config", function($rootScope, $scope, $http, $MD5, config) {
            $scope.shuffle = function(__array) {
                for (var j, x, i = __array.length; i; j = Math.floor(Math.random() * i), x = __array[--i], 
                __array[i] = __array[j], __array[j] = x) ;
                return __array;
            };
            var _id = null;
            $scope.requestExterno = function(__event) {
                var user = {
                    usuario: $scope.loginExterno,
                    password: $scope.passwordExterno
                };
                $scope.requestLogin(__event, user);
            };
            $scope.requestLogin = function(__event, user) {
                var parameter;
                if (!user.usuario || !user.password) {
                    $rootScope.alert("UsuÃ¡rio e Senha sÃ£o obrigatÃ³rios!");
                } else {
                    parameter = "usuario=" + user.usuario + "&senha=" + $MD5(user.password) + "&cenario=E";
                    $http({
                        url: "/intranet/autenticacao/login",
                        method: "POST",
                        data: parameter,
                        headers: {
                            "Content-Type": "application/x-www-form-urlencoded"
                        }
                    }).success(function(__response) {
                        if (__response.status === "s") {
                            var user = __response.dados.user;
                            if (user.id && user.indicadorTrocarSenha) {
                                _id = user.id;
                                $("#modalSenhaCentral").modal();
                            } else {
                                window.location = config.BASE_URL + "/intranet";
                            }
                        } else {
                            $rootScope.alert(__response.mensagem);
                        }
                    }).error(function(__response) {
                        $rootScope.alert(__response.mensagem);
                    });
                }
            };
            $scope.requestPassword = function(__event) {
                if (!$scope.senha.senhaAntiga || !$scope.senha.novaSenha || !$scope.senha.confirmacaoNovaSenha) {
                    $rootScope.alert("Os trÃªs campos sÃ£o obrigatÃ³rios!");
                    return;
                }
                if ($scope.passwordExterno != $scope.senha.senhaAntiga) {
                    $rootScope.alert("A senha antiga nÃ£o confere!");
                    return;
                }
                if ($scope.senha.novaSenha.length < 6) {
                    $rootScope.alert("A nova senha deve possuir no mÃ­nimo 6 caracteres.");
                    return;
                }
                if ($scope.senha.novaSenha != $scope.senha.confirmacaoNovaSenha) {
                    $rootScope.alert("A nova senha sÃ£o confere com a confirmaÃ§Ã£o!");
                    return;
                }
                var parameter = "senhaAntiga=" + $MD5($scope.senha.senhaAntiga) + "&senhaNova=" + $MD5($scope.senha.novaSenha) + "&idUsuario=" + _id;
                $http({
                    url: "/intranet/usuario/trocarSenha",
                    method: "POST",
                    data: parameter,
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                }).success(function(__response) {
                    if (__response.status === "e") {
                        $rootScope.alert(__response.mensagem);
                    } else {
                        $scope.passwordExterno = $scope.senha.novaSenha;
                        $("#modalSenhaCentral").modal("hide");
                        $scope.requestLogin(null, {
                            usuario: $scope.loginExterno,
                            password: $scope.passwordExterno
                        });
                    }
                });
            };
            $scope.requestRetrievePassword = function(__event) {
                if (!$scope.recuperarSenha.email || !$scope.recuperarSenha.login) {
                    $rootScope.alert("Os campos sÃ£o obrigatÃ³rios");
                    return;
                }
                if ($scope.recuperarSenha.email.toLowerCase() != $scope.recuperarSenha.email) {
                    $rootScope.alert("O e-mail informado deve conter apenas letras minÃºsculas.");
                    return;
                }
                var parameter = "login=" + $scope.recuperarSenha.login + "&email=" + $scope.recuperarSenha.email;
                $http({
                    url: "/intranet/usuario/recuperarSenha",
                    method: "POST",
                    data: parameter,
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                }).success(function(__response) {
                    $rootScope.alert(__response.mensagem, "bg-success");
                }).error(function(__response) {
                    $rootScope.alert(__response.mensagem);
                });
            };
            $scope.requestValidateQuestions = function(__event) {
                __event.preventDefault();
                __event.stopPropagation();
                if (!$scope.car || !$scope.document) {
                    $rootScope.alert("Os campos NÃºmero do Recibo e CPF / CNPJ do ProprietÃ¡rio / Possuidor sÃ£o obrigatÃ³rios.");
                    return;
                }
                var cpfCnpj = $scope.document;
                cpfCnpj = cpfCnpj.replace(/\D/g, "");
                var car = $scope.car;
                $http({
                    url: "/intranet/autenticacao/listarPerguntasVerificacao",
                    params: {
                        cpfCnpj: cpfCnpj,
                        car: car.replace(/\./g, "")
                    },
                    method: "get"
                }).success(function(__response) {
                    if (__response.status === "s") {
                        if (__response.dados) {
                            if (cpfCnpj.length == 11) {
                                $scope.perguntas.pessoaFisica.nomeMae = __response.dados.nomeMae;
                                $scope.perguntas.pessoaFisica.dataNascimento = __response.dados.dataNascimento;
                                $scope.perguntas.pessoaFisica.municipio = __response.dados.municipio;
                                $scope.activeSection = "perguntasPessoaFisica";
                                $scope.atual = "perguntasPessoaFisica";
                            } else if (cpfCnpj.length == 14) {
                                $scope.perguntas.pessoaJuridica.nomeCompleto = __response.dados.nomeCompleto;
                                $scope.perguntas.pessoaJuridica.municipio = __response.dados.municipio;
                                $scope.activeSection = "perguntasPessoaJuridica";
                                $scope.atual = "perguntasPessoaJuridica";
                            }
                        } else {
                            $rootScope.alert("O servidor nÃ£o enviou nenhuma resposta sobre a validaÃ§Ã£o do CAR - CPF / CNPJ");
                        }
                    } else {
                        $rootScope.alert(__response.mensagem);
                    }
                }).error(function(__response) {
                    $rootScope.alert(__response.mensagem);
                });
            };
            $scope.showFormPessoaFisica = function(__event) {
                $scope.requestValidate(__event, $scope.respostas.pessoaFisica, "PF");
            };
            $scope.showFormPessoaJuridica = function(__event) {
                $scope.requestValidate(__event, $scope.respostas.pessoaJuridica, "PJ");
            };
            $scope.requestValidate = function(__event, __data, __tipoPessoa) {
                var _url;
                var _cpfCnpj = $scope.document.replace(/\D/g, "");
                var _request = $.extend(true, {}, __data);
                if (__tipoPessoa === "PF") {
                    if (!_request.nomeMae || !_request.dataNascimento || !_request.municipio) {
                        $rootScope.alert("Os parÃ¢metros Nome da MÃ£e, Data de Nascimento e MunicÃ­pio sÃ£o obrigatÃ³rios.");
                        return;
                    }
                    _url = "/intranet/autenticacao/validarPerguntasVerificacaoPessoaFisica";
                    _request.cpf = _cpfCnpj;
                    _request.dataNascimento = __data.dataNascimento.split(" ")[0];
                } else {
                    if (!_request.nomeCompleto || !_request.municipio) {
                        $rootScope.alert("Os parÃ¢metros Nome / RazÃ£o Social e MunicÃ­pio sÃ£o obrigatÃ³rios.");
                        return;
                    }
                    _url = "/intranet/autenticacao/validarPerguntasVerificacaoPessoaJuridica";
                    _request.cnpj = _cpfCnpj;
                }
                _request.car = $scope.car.replace(/\./g, "");
                $scope.pessoa.pessoa = {};
                $http({
                    url: _url,
                    params: _request,
                    method: "GET"
                }).success(function(__response) {
                    if (__response.status === "s") {
                        if (__response.dados) {
                            $scope.pessoa.pessoa.nome = __response.dados.nomeCompleto;
                            $scope.pessoa.pessoa.cpfCnpj = __response.dados.cpfCnpj;
                            if (__response.dados.tipoPessoa === "PF") {
                                $scope.pessoa.pessoa.tipo = "F";
                                $scope.pessoa.fisica.dataNascimento = __response.dados.dataNascimento.substr(0, 10);
                                $scope.pessoa.fisica.nomeMae = __response.dados.nomeMae;
                                $scope.pessoa.fisica.cpfConjuge = "";
                                $scope.pessoa.fisica.nomeConjuge = "";
                                $scope.activeSection = "pessoaFisica";
                                $scope.atual = "pessoaFisica";
                            } else if (__response.dados.tipoPessoa === "PJ") {
                                $scope.pessoa.pessoa.tipo = "J";
                                $scope.pessoa.juridica.nomeFantasia = __response.dados.nomeFantasia || " ";
                                $scope.activeSection = "pessoaJuridica";
                                $scope.atual = "pessoaJuridica";
                            } else {
                                $rootScope.alert("Documento invÃ¡lido.");
                            }
                        } else {
                            $rootScope.alert("O servidor nÃ£o enviou nenhuma resposta sobre a validaÃ§Ã£o do CAR - CPF / CNPJ");
                        }
                    } else {
                        $rootScope.alert(__response.mensagem);
                    }
                }).error(function(__response) {
                    $rootScope.alert(__response.mensagem);
                });
            };
            $scope.requestSave = function(__event) {
                if (!$scope.pessoa.pessoa.email) {
                    $rootScope.alert("O E-Mail Ã© obrigatÃ³rio");
                    return;
                }
                if ($scope.pessoa.pessoa.email != $scope.pessoa.pessoa.confirmacaoEmail) {
                    $rootScope.alert("O E-Mail nÃ£o confere com a confirmaÃ§Ã£o.");
                    return;
                }
                var _usuario = {
                    login: $scope.pessoa.pessoa.cpfCnpj
                };
                var _pessoa = $.extend(true, {}, $scope.pessoa.pessoa);
                delete _pessoa.confirmacaoEmail;
                var parameter = null;
                if ($scope.activeSection === "pessoaFisica") {
                    var _fisica = $.extend(true, {}, $scope.pessoa.fisica);
                    _fisica.dataNascimento += " 00:00:00";
                    parameter = "usuario=" + JSON.stringify(_usuario).replace(/&/g, "%26") + "&pessoa=" + JSON.stringify(_pessoa).replace(/&/g, "%26") + "&pessoaFisica=" + JSON.stringify(_fisica).replace(/&/g, "%26");
                } else if ($scope.activeSection === "pessoaJuridica") {
                    parameter = "usuario=" + JSON.stringify(_usuario).replace(/&/g, "%26") + "&pessoa=" + JSON.stringify(_pessoa).replace(/&/g, "%26") + "&pessoaJuridica=" + JSON.stringify($scope.pessoa.juridica).replace(/&/g, "%26");
                } else {
                    $rootScope.alert("Formato de usuÃ¡rio nÃ£o especificado!");
                    return;
                }
                $http({
                    url: "/intranet/usuario/cadastrarExterno",
                    method: "POST",
                    data: parameter,
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                }).success(function(__response) {
                    var tituloClass;
                    if (__response.status === "s") {
                        tituloClass = "bg-success";
                        $("#modalPessoaJuridica").modal("hide");
                        $("#modalPessoaFisica").modal("hide");
                        $("#modalAlert").one("hide.bs.modal", function() {
                            window.location.hash = "#/";
                            window.location.reload();
                        });
                    } else {
                        tituloClass = "bg-danger";
                    }
                    $rootScope.alert(__response.mensagem, tituloClass);
                }).error(function(__response) {
                    $rootScope.alert(__response.mensagem);
                });
            };
            $scope.visivel = function(testar) {
                return $scope.atual === testar;
            };
            $scope.irPara = function(ir) {
                $scope.atual = ir;
            };
            $scope.init = function() {
                $scope.idExterno = 2;
                $scope.recuperarSenha = {
                    email: null,
                    login: null
                };
                $scope.perguntas = {
                    pessoaFisica: {
                        nomeMae: null,
                        dataNascimento: null,
                        municipio: null
                    },
                    pessoaJuridica: {
                        nomeCompleto: null,
                        municipio: null
                    }
                };
                $scope.respostas = {
                    pessoaFisica: {
                        nomeMae: null,
                        dataNascimento: null,
                        municipio: null
                    },
                    pessoaJuridica: {
                        nomeCompleto: null,
                        municipio: null
                    }
                };
                $scope.car = null;
                $scope.configTela = {
                    carExemplo: "UF-1302405-E6D3.395B.6D27.4F42.AE22.DD56.987C.DD52"
                };
                $scope.document = null;
                $scope.senha = {
                    senhaAntiga: null,
                    novaSenha: null,
                    confirmacaoNovaSenha: null
                };
                $scope.atual = "principal";
                $scope.pessoa = {
                    pessoa: {
                        nome: null,
                        tipo: null,
                        cpfCnpj: null,
                        telefone: null,
                        celular: null,
                        email: null,
                        confirmacaoEmail: null
                    },
                    fisica: {
                        dataNascimento: null,
                        nomeMae: null,
                        cpfConjuge: null,
                        nomeConjuge: null
                    },
                    juridica: {
                        nomeFantasia: null
                    }
                };
                $scope.obj = {};
                $("input#tiConfirmacaoEmailJ, input#tiEmailJ").bind({
                    copy: function(e) {
                        e.preventDefault();
                    },
                    paste: function(e) {
                        e.preventDefault();
                    },
                    cut: function(e) {
                        e.preventDefault();
                    }
                });
            };
            $scope.init();
        } ]);
    })();
    (function() {
        angular.module("acessarServico", [ "ngResource" ]).factory("$ajax", [ "$resource", "$http", function($resource, $http) {
            $http.defaults.headers.post = {
                "Content-Type": "application/x-www-form-urlencoded"
            };
            return {
                getResource: function(url, params) {
                    var x = $resource(url, params);
                    x.post = function(data, callback) {
                        x.save(decodeURIComponent($.param(data)), function(retorno) {
                            callback(retorno);
                        }, function() {});
                    };
                    return x;
                },
                tratarRetorno: function(json) {
                    if (json.status === "s") {
                        return json.dados;
                    }
                    if (json.status === "a") {
                        return {
                            dados: json.dados,
                            mensagem: json.mensagem
                        };
                    }
                    if (json.status === "e") {
                        return json.mensagem;
                    }
                    return json;
                }
            };
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("CentralAcessoCtrl", [ "$scope", "$rootScope", "$location", "centralService", "config", function($scope, $rootScope, $location, centralService, config) {
            $scope.acessar = function(usuario, senha) {
                if (_(usuario).isEmpty() || _(senha).isEmpty()) {
                    $rootScope.alert("UsuÃ¡rio e Senha sÃ£o obrigatÃ³rios!");
                    return;
                }
                centralService.autenticacao(usuario, senha).success(function(response) {
                    if (response.status === "s") {
                        var user = response.dados.user;
                        if (user.id && user.indicadorTrocarSenha) {
                            $rootScope.$broadcast("abrirModalTrocarSenha", user.id, usuario, senha);
                        } else {
                            if (response.dados.profiles && response.dados.profiles.length > 1) {
                                $scope.profiles = response.dados.profiles;
                                $("#modalPerfilCentral").modal();
                            } else {
                                if (response.dados.profile) {
                                    window.location = config.BASE_URL + "/intranet";
                                } else {
                                    _id = null;
                                    $scope.profiles = null;
                                    $rootScope.alert("O serviÃ§o de autenticaÃ§Ã£o se comportou de maneira inesperada. Tente efetuar login novamente.");
                                }
                            }
                        }
                    } else {
                        $rootScope.alert(response.mensagem);
                    }
                }).error(function(response) {
                    $rootScope.alert(response.mensagem);
                });
            };
            $scope.validarUsuario = function(codigoImovel, cpfCnpj) {
                if (_(codigoImovel).isEmpty() || _(cpfCnpj).isEmpty()) {
                    $rootScope.alert("Os campos NÃºmero do Recibo e CPF / CNPJ do ProprietÃ¡rio / Possuidor sÃ£o obrigatÃ³rios.");
                    return;
                }
                centralService.listarPerguntasVerificacao(codigoImovel, cpfCnpj).success(function(response) {
                    if (response.status === "e") {
                        $rootScope.alert(response.mensagem);
                        return;
                    }
                    if (_(response.dados).isEmpty()) {
                        $rootScope.alert("Inconformidades no retorno do serviÃ§o de validaÃ§Ã£o.");
                        return;
                    }
                    centralService.codigoImovel(codigoImovel);
                    centralService.perguntasVerificacao(response.dados);
                    centralService.cpfCnpj(cpfCnpj);
                    if (response.dados.isRepresentanteLegal || !cpfCnpj.isCPF()) {
                        $location.path("/central/pessoaJuridica");
                    } else if (response.dados.isRepresentante) {
                        if (response.dados.cpfCnpjProprietario.isCPF()) {
                            $location.path("/central/pessoaFisica");
                        } else {
                            $location.path("/central/pessoaJuridica");
                        }
                    } else {
                        $location.path("/central/pessoaFisica");
                    }
                }).error(function(response) {
                    $rootScope.alert(response.mensagem);
                    return;
                });
            };
            $scope.selecionarPerfil = function(perfil) {
                if (!perfil || !perfil.id) {
                    $rootScope.alert("O identificador do perfil nÃ£o foi selecionado.");
                    return;
                }
                var data = "perfil=" + perfil.id;
                centralService.escolherPerfil(data).success(function(response) {
                    if (response.status === "s") {
                        window.location = config.BASE_URL + "/intranet";
                    } else {
                        $rootScope.alert(response.mensagem);
                    }
                });
            };
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("BaixarCtrl", [ "$scope", "baixarService", "estadosService", "versaoCadastroService", "config", "$uibModal", function($scope, baixarService, estadosService, versaoCadastroService, config, $uibModal) {
            var osConfig = {
                Windows: {
                    value: "WIN",
                    extension: ".exe"
                },
                Mac: {
                    value: "MAC",
                    extension: ".dmg"
                },
                Linux_deb: {
                    value: "LIN_DEB",
                    extension: ".deb"
                },
                Linux_rpm: {
                    value: "LIN_RPM",
                    extension: ".rpm"
                }
            };
            $scope.openModalBaixarModuloCadastro = function() {
                var modalInstance = $uibModal.open({
                    templateUrl: "sections/modalBaixarModuloCadastro.html",
                    controller: "ModalBaixarModuloCtrl",
                    backdrop: "static",
                    keyboard: false,
                    resolve: {
                        osSelecionado: function() {
                            return $scope.osSelecionado;
                        },
                        osConfig: function() {
                            return osConfig;
                        },
                        linuxPackageType: function() {
                            return $scope.linuxPackage.type;
                        }
                    }
                });
            };
            $scope.estadoSelecionado = undefined;
            $scope.osSelecionado = "Windows";
            $scope.versaoArquivoCadastro = "-";
            $scope.nomeArquivo = "CAR";
            $scope.tamanhoArquivo = "450mb";
            $scope.deAcordoComTermos = false;
            $scope.linuxPackage = {
                type: "deb"
            };
            var statusEstados;
            estadosService.list(function(data) {
                $scope.estados = data.dados;
            });
            estadosService.status(function(data) {
                statusEstados = data.dados.estados;
            });
            $scope.selecionarEstado = function(estado) {
                var url = urlDoSistemaDoEstado(estado.id);
                if (url) {
                    window.open(url, "_blank");
                } else {
                    $scope.estadoSelecionado = estado;
                }
            };
            $scope.voltarTelaEstados = function() {
                $scope.estadoSelecionado = undefined;
            };
            $scope.nomeArquivoPorOS = function() {
                var name = getOS();
                var osData = osConfig[name];
                if (osData) {
                    return $scope.nomeArquivo + "_" + $scope.versaoArquivoCadastro + osData.extension;
                }
            };
            var urlDoSistemaDoEstado = function(sigla) {
                var url;
                $.each(statusEstados, function(index, estado) {
                    if (estado.sigla == sigla) {
                        url = estado.urlBaixar;
                    }
                });
                return url;
            };
            var onDownload = function() {
                console.log(arguments);
            };
            var obterVersaoCadastro = function() {
                versaoCadastroService.versaoCadastro(function(data) {
                    $scope.versaoArquivoCadastro = data;
                });
            };
            obterVersaoCadastro();
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("baixarService", [ "$http", "config", "requestUtil", function($http, config, requestUtil) {
            var service = {};
            service.baixar = function(versao, successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/download/car/" + versao, successCallback, errorCallback);
            };
            return service;
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("BuscaCtrl", [ "$scope", "pesquisaSiteService", "$location", function($scope, pesquisaSiteService, $location) {
            $scope.pesquisa = {
                filtroPesquisa: ""
            };
            pesquisaSiteService.buscarOpcoesPesquisa(function(response) {
                $scope.opcoesBusca = response;
            });
            pesquisaSiteService.listMaisBuscados(function(response) {
                $scope.maisBuscados = response;
            });
            $scope.redirecionar = function(item) {
                pesquisaSiteService.redirecionar(item);
                pesquisaSiteService.incrementarPesquisaRealizada(item.id);
            };
            $scope.pesquisar = function() {
                $location.path("/busca").search({
                    termoPesquisado: $scope.pesquisa.filtroPesquisa
                });
            };
            $scope.termoPesquisado = $location.search().termoPesquisado;
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("centralService", [ "$http", "$MD5", "requestUtil", function($http, $MD5, requestUtil) {
            var service = {};
            service.autenticacao = function(usuario, senha) {
                var parameter = "usuario=" + usuario + "&senha=" + $MD5(senha) + "&cenario=E";
                return $http({
                    url: "intranet/autenticacao/login",
                    method: "POST",
                    data: parameter,
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                });
            };
            service.listarPerguntasVerificacao = function(codigoImovel, cpfCnpj) {
                return $http({
                    url: "intranet/autenticacao/listarPerguntasVerificacao",
                    params: {
                        cpfCnpj: cpfCnpj.replace(/\D/g, ""),
                        car: codigoImovel.replace(/\./g, "")
                    },
                    method: "get"
                });
            };
            var _perguntas;
            service.perguntasVerificacao = function(perguntas) {
                if (perguntas) {
                    _respostas = perguntas.nomeMae || perguntas.nomeCompleto;
                    _perguntas = perguntas;
                }
                return _perguntas;
            };
            var _codigoImovel;
            service.codigoImovel = function(codigoImovel) {
                if (codigoImovel) {
                    _codigoImovel = codigoImovel;
                }
                return _codigoImovel;
            };
            var _respostas;
            service.respostas = function(respostas) {
                if (respostas) {
                    _respostas = respostas;
                }
                return _respostas;
            };
            var _cpfCnpj;
            service.cpfCnpj = function(cpfCnpj) {
                if (cpfCnpj) {
                    _cpfCnpj = cpfCnpj;
                }
                return _cpfCnpj;
            };
            service.validarPessoaFisica = function(pessoa) {
                return $http({
                    url: "intranet/autenticacao/validarPerguntasVerificacaoPessoaFisica",
                    method: "POST",
                    data: $.param({
                        resposta: pessoa
                    }),
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                });
            };
            service.validarPessoaJuridica = function(pessoa) {
                return $http({
                    url: "/intranet/autenticacao/validarPerguntasVerificacaoPessoaJuridica",
                    method: "POST",
                    data: $.param({
                        resposta: pessoa
                    }),
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                });
            };
            service.buscarInformacoesPessoa = function(idImovelPessoa, hash) {
                return $http.get("imoveisPessoas/" + idImovelPessoa + "/validar/" + hash);
            };
            service.buscarInformacoesRepresentante = function(idRepresentante, hash) {
                return $http.get("representantes/" + idRepresentante + "/validar/" + hash);
            };
            service.buscarInformacoesRepresentanteLegal = function(idRepresentanteLegal, hash) {
                return $http.get("representantesLegais/" + idRepresentanteLegal + "/validar/" + hash);
            };
            service.cadastrarPessoaFisica = function(pessoa, pessoaFisica, representante, senha, hash) {
                return $http({
                    url: "intranet/usuario/pessoaFisica",
                    method: "POST",
                    data: $.param({
                        usuario: {
                            login: pessoa.cpfCnpj,
                            senha: $MD5(senha)
                        },
                        pessoa: pessoa,
                        pessoaFisica: pessoaFisica,
                        representante: representante,
                        hash: hash
                    }),
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                });
            };
            service.cadastrarPessoaJuridica = function(nome, cnpj, nomeFantasia, email, telefone, celular, senha, hash) {
                return $http({
                    url: "intranet/usuario/pessoaJuridica",
                    method: "POST",
                    data: $.param({
                        usuario: {
                            login: cnpj,
                            senha: $MD5(senha)
                        },
                        pessoa: {
                            nome: nome,
                            cpfCnpj: cnpj,
                            email: email,
                            telefone: telefone,
                            celular: celular
                        },
                        pessoaJuridica: {
                            nomeFantasia: nomeFantasia
                        },
                        hash: hash
                    }),
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                });
            };
            service.escolherPerfil = function(data) {
                return $http({
                    url: "/intranet/autenticacao/perfilExterno",
                    method: "POST",
                    data: data,
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                });
            };
            return service;
        } ]);
    })();
    (function() {
        function getHost() {
            return window.location.protocol + "//" + window.location.host;
        }
        var modulo = angular.module("SICAR");
        modulo.factory("config", function() {
            var defaultConfig = {
                BASE_URL: getHost()
            };
            return defaultConfig;
        });
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("ConsultarCtrl", [ "$http", "$scope", "consultarService", "$routeParams", "config", "$location", function($http, $scope, consultarService, $routeParams, config, $location) {
            $scope.init = function() {
                if ($routeParams.codigo) {
                    $scope.configTela.displayBotaoConsultar = "enabled";
                    $scope.car = $routeParams.codigo;
                    $scope.consultar();
                }
            };
            $scope.limpaPesquisa = function() {
                $scope.car = "";
            };
            $scope.configTela = {};
            $scope.configTela.displayBotaoConsultar = true;
            $scope.configTela.displayDemonstrativo = false;
            $scope.configTela.displayCARNaoEncontrado = false;
            $scope.configTela.srcImageDownload = "./img/download-pdf.png";
            $scope.configTela.carExemplo = "UF-1302405-E6D3.395B.6D27.4F42.AE22.DD56.987C.DD52";
            function formataCodigoCar(car) {
                var formatado = car ? car.replace(/\./g, "") : "";
                return formatado;
            }
            $scope.voltar = function() {
                $scope.configTela.displayBotaoConsultar = true;
                $scope.configTela.displayDemonstrativo = false;
                $scope.configTela.displayCARNaoEncontrado = false;
            };
            $scope.consultar = function() {
                var demonstrativoUrl = config.BASE_URL + "/imovel/demonstrativo/" + formataCodigoCar($scope.car) + "/gerar";
                $http.get(demonstrativoUrl).then(function(response) {
                    if (response.data.status === "s") {
                        $scope.demonstrativo = response.data.dados;
                        $scope.configTela.displayBotaoConsultar = false;
                        $scope.configTela.displayCARNaoEncontrado = false;
                        $scope.configTela.displayDemonstrativo = true;
                    } else {
                        $scope.configTela.displayCARNaoEncontrado = true;
                    }
                });
            };
            $scope.downloadPdfDemonstrativo = function() {
                var baixarUrl = "";
                var gerarUrl = config.BASE_URL + "/pdf/demonstrativo/" + formataCodigoCar($scope.car) + "/gerar";
                $http.get(gerarUrl).then(function(response) {
                    baixarUrl = response.data.dados;
                    location.href = baixarUrl;
                });
            };
            $scope.abrirVersaoImpressao = function() {
                window.print();
            };
            $scope.getAreaFormatada = function(area) {
                if (area) {
                    return area.formatarNumero(2) + " ha";
                } else {
                    return "-";
                }
            };
            $scope.getAreaFormatadaPassivoExcedente = function(area) {
                if (area) {
                    if (area > 0) {
                        return "(excedente) + " + area.formatarNumero(2) + " ha";
                    } else if (area < 0) {
                        return "(passivo) - " + Math.abs(area).formatarNumero(2) + " ha";
                    } else {
                        return area.formatarNumero(2) + " ha";
                    }
                } else {
                    return "-";
                }
            };
            $scope.getStyleArea = function(area) {
                if (!area) {
                    return "";
                }
                var cor = "";
                if (area > 0) {
                    cor = {
                        color: "#3AB930"
                    };
                } else if (area < 0) {
                    cor = {
                        color: "#B20000"
                    };
                }
                return cor;
            };
            $scope.getStyleSituacao = function(situacao) {
                var cor = "#666";
                if (situacao === "Aprovada") {
                    cor = "#3AB930";
                }
                if (situacao === "NÃ£o Aprovada") {
                    cor = "#B20000";
                }
                return {
                    "background-color": cor
                };
            };
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("consultarService", [ "$http", "config", "requestUtil", function($http, config, requestUtil) {
            var service = {};
            service.consultar = function(car, successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/imovel/" + car + "/false", function(data) {
                    if (data.dados) {
                        successCallback(data);
                    } else {
                        errorCallback(data);
                    }
                }, function(data) {
                    errorCallback(data);
                });
            };
            service.downloadRecibo = function(car, successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/pdf/" + car + "/gerar", function(data) {
                    if (data.dados !== "") {
                        window.location.href = config.BASE_URL + data.dados;
                    } else {
                        errorCallback(data);
                    }
                }, function(data) {
                    errorCallback(data);
                });
            };
            return service;
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("ContatosCtrl", [ "$scope", "$location", function($scope, $location) {
            $scope.states = [ {
                uf: "AC",
                label: "Acre"
            }, {
                uf: "AL",
                label: "Alagoas"
            }, {
                uf: "AP",
                label: "AmapÃ¡"
            }, {
                uf: "AM",
                label: "Amazonas"
            }, {
                uf: "BA",
                label: "Bahia"
            }, {
                uf: "CE",
                label: "CearÃ¡"
            }, {
                uf: "DF",
                label: "Distrito Federal"
            }, {
                uf: "ES",
                label: "EspÃ­rito Santo"
            }, {
                uf: "GO",
                label: "GoiÃ¡s"
            }, {
                uf: "MA",
                label: "MaranhÃ£o"
            }, {
                uf: "MT",
                label: "Mato Grosso"
            }, {
                uf: "MS",
                label: "Mato Grosso do Sul"
            }, {
                uf: "MG",
                label: "Minas Gerais"
            }, {
                uf: "PA",
                label: "ParÃ¡"
            }, {
                uf: "PB",
                label: "ParaÃ­ba"
            }, {
                uf: "PR",
                label: "ParanÃ¡"
            }, {
                uf: "PE",
                label: "Pernambuco"
            }, {
                uf: "PI",
                label: "PiauÃ­"
            }, {
                uf: "RJ",
                label: "Rio de Janeiro"
            }, {
                uf: "RN",
                label: "Rio Grande do Norte"
            }, {
                uf: "RS",
                label: "Rio Grande do Sul"
            }, {
                uf: "RO",
                label: "RondÃ´nia"
            }, {
                uf: "RR",
                label: "Roraima"
            }, {
                uf: "SC",
                label: "Santa Catarina"
            }, {
                uf: "SP",
                label: "SÃ£o Paulo"
            }, {
                uf: "SE",
                label: "Sergipe"
            }, {
                uf: "TO",
                label: "Tocantins"
            } ];
            $scope.abrirVersaoImpressao = function() {
                window.print();
            };
            $scope.gotoAnchor = function(x) {
                var newHash = "anchor" + x;
                if ($location.hash() !== newHash) {
                    $location.hash("anchor" + x);
                } else {
                    $anchorScroll();
                }
            };
            $scope.setarAbaAtual = function(aba) {
                $scope.$parent.setarAbaAtual(aba);
            };
            $(window).scroll(function() {
                if ($(this).scrollTop() > 200) {
                    $(".goToTop").fadeIn();
                } else {
                    $(".goToTop").fadeOut();
                }
            });
            $(".goToTop").click(function() {
                $("html, body").animate({
                    scrollTop: 0
                }, 1e3);
                return false;
            });
        } ]);
    })();
    angular.module("SICAR").directive("cpfCnpj", function() {
        return {
            require: "ngModel",
            restrict: "A",
            link: function(scope, element, attrs, controller) {
                controller.$parsers.push(function(value) {
                    var transformedValue = applyMask(value);
                    if (attrs.validate) validate(transformedValue);
                    return transformedValue;
                });
                controller.$formatters.push(function(value) {
                    var transformedValue = applyMask(value);
                    if (attrs.validate) validate(transformedValue);
                    return transformedValue;
                });
                element.change(function() {
                    var value = element.val();
                    scope.$apply(function() {
                        if (attrs.validate) validate(value);
                    });
                });
                element.focusin(function() {
                    limpaMascara();
                });
                element.focusout(function() {
                    limpaMascara();
                });
                function limpaMascara() {
                    if (element.val().length !== 14 && element.val().length !== 18) {
                        scope.$eval(attrs.ngModel + " = ''");
                        scope.$digest();
                    }
                }
                function validate(value) {
                    if (!value) controller.$setValidity("cpfCnpj", true); else if (value.length <= 14) controller.$setValidity("cpfCnpj", !value || value.isCPF()); else controller.$setValidity("cpfCnpj", !value || value.isCNPJ());
                }
                function applyMask(value) {
                    if (value === undefined || !value) return undefined;
                    var transformedValue = cpfCnpj(value);
                    transformedValue = transformedValue.substring(0, 51);
                    if (transformedValue != value) {
                        controller.$setViewValue(transformedValue);
                        controller.$render();
                    }
                    return transformedValue;
                }
                function cpfCnpj(value) {
                    value = value.replace(/\D/g, "");
                    if (value.length <= 11) {
                        value = value.replace(/(\d{3})(\d)/, "$1.$2");
                        value = value.replace(/(\d{3})(\d)/, "$1.$2");
                        value = value.replace(/(\d{3})(\d{1,2})$/, "$1-$2");
                    } else {
                        value = value.replace(/^(\d{2})(\d)/, "$1.$2");
                        value = value.replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3");
                        value = value.replace(/\.(\d{3})(\d)/, ".$1/$2");
                        value = value.replace(/(\d{4})(\d)/, "$1-$2");
                    }
                    return value;
                }
            }
        };
    });
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("EnviarCtrl", [ "$scope", "enviarService", "consultarService", "config", function($scope, enviarService, consultarService, config) {
            $scope.enviado = false;
            $scope.urlPdf = "";
            $scope.arquivoAdicionado = false;
            $scope.fileName = "";
            $scope.uploadErrors = [];
            $scope.envioLiberado = true;
            var dropzone;
            enviarService.liberado(function(value) {
                $scope.envioLiberado = value.toString() == "true";
            });
            $scope.contextoId = "";
            $scope.captcha = "";
            enviarService.getContextoId(function(idContexto) {
                $scope.contextoId = idContexto;
                $scope.urlImagemCaptcha = config.BASE_URL + "/captcha/gerar?id=" + $scope.contextoId;
            });
            $scope.atualizarCaptcha = function() {
                enviarService.getContextoId(function(idContexto) {
                    $scope.contextoId = idContexto;
                    $scope.urlImagemCaptcha = config.BASE_URL + "/captcha/gerar?id=" + $scope.contextoId;
                });
            };
            $scope.abrirModalAviso = function() {
                $("#AvisoCarFuncionando").modal();
            };
            $scope.setarAbaAtual = function(aba) {
                init();
                $scope.$parent.setarAbaAtual(aba);
            };
            var init = function() {
                dropzone = new Dropzone("form#dropzone-car", {
                    url: config.BASE_URL + "/imovel/enviar?id=" + $scope.contextoId + "&captcha=" + $scope.captcha
                });
                if (dropzone.options) {
                    dropzone.options.autoProcessQueue = false;
                    dropzone.options.uploadMultiple = false;
                    dropzone.options.paramName = "car";
                    dropzone.options.maxFiles = 1;
                }
                dropzone.on("addedfile", function(file) {
                    $scope.arquivoAdicionado = true;
                    if (file && file.name) {
                        $scope.fileName = file.name;
                    }
                    $scope.uploadErrors = [];
                    digest("dropzone.addedfile");
                });
                dropzone.on("success", function(file, response) {
                    clearInput();
                    $("#ModalAguardeEnvioCar").modal("hide");
                    $scope.atualizarCaptcha();
                    dropzone.removeAllFiles();
                    if (response.codigoResposta && response.codigoResposta.toString() == "200") {
                        $scope.enviado = true;
                        $scope.respostaUpload = response;
                    } else {
                        $scope.uploadErrors = response.mensagensResposta;
                        console.log(response.mensagensResposta);
                    }
                    digest("dropzone.success");
                });
                dropzone.on("error", function(err, msg) {
                    clearInput();
                    $("#ModalAguardeEnvioCar").modal("hide");
                    $scope.atualizarCaptcha();
                    dropzone.removeAllFiles();
                    console.log("ERRO:", err, msg);
                    $scope.uploadErrors = [ "Ocorreu um problema ao enviar seu cadastro. Por favor, tente novamente mais tarde." ];
                    digest("dropzone.error");
                });
            };
            var digest = function(parentFunction) {
                try {
                    $scope.$digest();
                } catch (e) {
                    console.log("Can't digest " + parentFunction + ". Skipping.");
                }
            };
            var clearInput = function() {
                $scope.arquivoAdicionado = false;
                $scope.fileName = "";
            };
            $scope.enviar = function(evt) {
                $("#ModalAguardeEnvioCar").modal({
                    backdrop: "static",
                    keyboard: false
                });
                var btn = $(evt.currentTarget);
                dropzone.options.url = config.BASE_URL + "/imovel/enviar?id=" + $scope.contextoId + "&captcha=" + $scope.captcha;
                dropzone.processQueue();
                $scope.captcha = "";
                digest("enviar");
            };
            $scope.novoEnvio = function() {
                dropzone.removeAllFiles();
                $scope.uploadErrors = [];
                $scope.enviado = false;
                $scope.respostaUpload = {};
                $scope.atualizarCaptcha();
            };
            $scope.baixarPDF = function() {
                var car = $scope.respostaUpload.codigoImovel.split(".").join("");
                consultarService.downloadRecibo(car, function success() {
                    console.log("Recibo gerado com sucesso");
                }, function error() {
                    console.log("Erro ao gerar recibo");
                });
            };
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("enviarService", [ "$http", "config", "requestUtil", function($http, config, requestUtil) {
            var service = {};
            service.liberado = function(successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/car/envioliberado", successCallback, errorCallback);
            };
            service.getContextoId = function(successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/captcha/id", successCallback, errorCallback);
            };
            service.validarCaptcha = function(captchaDigitado, idContexto, successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/captcha/validar?captcha=" + captchaDigitado + "&id=" + idContexto, successCallback, errorCallback);
            };
            return service;
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("estadosService", [ "$http", "config", "requestUtil", function($http, config, requestUtil) {
            var service = {};
            service.list = function(successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/estados/all", successCallback, errorCallback);
            };
            service.status = function(successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/estados/status", successCallback, errorCallback);
            };
            return service;
        } ]);
    })();
    (function() {
        var FormUtils = function(scope, formName) {
            this.scope = scope;
            this.formName = formName || "form";
            this._fields = null;
        };
        FormUtils.prototype.getForm = function() {
            return this.scope[this.formName];
        };
        FormUtils.prototype.setDirty = function(fieldsNames) {
            this._eachField(function(field) {
                setDirtyAttribute(field, true);
            }, fieldsNames);
        };
        FormUtils.prototype.cleanDirty = function(fieldsNames) {
            this._eachField(function(field) {
                setDirtyAttribute(field, false);
            }, fieldsNames);
        };
        FormUtils.prototype.cleanCustomValidations = function(fieldsNames) {
            var self = this;
            this._eachField(function(field) {
                for (var err in field.model.$error) {
                    if (isCustomValidation(err) && field.model.$error[err]) {
                        field.model.$setValidity(err, true);
                    }
                }
            }, fieldsNames);
        };
        FormUtils.prototype.validate = function() {
            var fields = this.getFields();
            for (var i in fields) {
                if (!fields[i].model.$valid) return false;
            }
            return true;
        };
        FormUtils.prototype.getFields = function() {
            if (!this._fields) this._loadFields();
            return this._fields;
        };
        FormUtils.prototype._loadFields = function() {
            this._fields = {};
            var form = this.getForm();
            for (var prop in form) {
                if (form.hasOwnProperty(prop) && prop.indexOf("$") !== 0) this._addElement(form, prop);
            }
        };
        FormUtils.prototype._addElement = function(form, name) {
            this._fields[name] = {
                elem: $("[name=" + name + "]"),
                model: form[name]
            };
        };
        FormUtils.prototype._eachField = function(func, fieldsNames) {
            var i = 0, fields = this.getFields();
            if (fieldsNames) {
                for (i = 0; i < fieldsNames.length; i++) {
                    func(fields[fieldsNames[i]]);
                }
            } else {
                for (i in fields) {
                    func(fields[i]);
                }
            }
        };
        var setDirtyAttribute = function(field, dirty) {
            field.elem.removeClass(dirty ? "ng-pristine" : "ng-dirty");
            field.elem.addClass(dirty ? "ng-dirty" : "ng-pristine");
            field.model.$dirty = dirty;
            field.model.$pristine = !dirty;
        };
        var isCustomValidation = function(validation) {
            return app.CustomValidations.indexOf(validation) >= 0;
        };
        exports.FormUtils = FormUtils;
    })();
    (function() {
        String.prototype.formatarCpfCnpj = function() {
            var v = this.toString().replace(/\D/g, "");
            if (v.length <= 11) {
                v = v.replace(/(\d{3})(\d)/, "$1.$2");
                v = v.replace(/(\d{3})(\d)/, "$1.$2");
                v = v.replace(/(\d{3})(\d{1,2})$/, "$1-$2");
            } else {
                v = v.replace(/^(\d{2})(\d)/, "$1.$2");
                v = v.replace(/^(\d{2})\.(\d{3})(\d)/, "$1.$2.$3");
                v = v.replace(/\.(\d{3})(\d)/, ".$1/$2");
                v = v.replace(/(\d{4})(\d)/, "$1-$2");
            }
            return v;
        };
        var formatarNumero = function(number, casas) {
            var numeros = number.toFixed(casas).toString().split(".");
            var esquerdo = numeros[0].replace(/\B(?=(\d{3})+(?!\d))/g, ".");
            var direito = numeros[1];
            return esquerdo + "," + direito;
        };
        String.prototype.formatarNumero = function(casas) {
            casas = casas || 2;
            return formatarNumero(parseFloat(this), casas);
        };
        Number.prototype.formatarNumero = function(casas) {
            casas = casas || 2;
            return formatarNumero(this, casas);
        };
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("CentralFormularioCtrl", [ "$scope", "$rootScope", "$location", "$routeParams", "centralService", "estadosService", "municipiosService", function($scope, $rootScope, $location, $routeParams, centralService, estadosService, municipiosService) {
            var tipoPessoa;
            $scope.isPessoaFisica = function() {
                return tipoPessoa === "PESSOA_FISICA";
            };
            $scope.cadastrar = function(informacoes) {
                if (_(informacoes.telefone).isEmpty()) {
                    $rootScope.alert('O campo "Telefone do ProprietÃ¡rio / Possuidor" Ã© obrigatÃ³rio.');
                    return;
                }
                if (_(informacoes.senha).isEmpty()) {
                    $rootScope.alert('O campo "Senha" Ã© obrigatÃ³rio.');
                    return;
                }
                if (informacoes.senha.length < 6) {
                    $rootScope.alert("A senha deverÃ¡ ter no mÃ­nimo 6 caracteres.");
                    return;
                }
                if (_(informacoes.confirmarSenha).isEmpty()) {
                    $rootScope.alert('O campo "Confirmar Senha" Ã© obrigatÃ³rio.');
                    return;
                }
                if (informacoes.senha !== informacoes.confirmarSenha) {
                    $rootScope.alert("A senha e a confirmaÃ§Ã£o de senha sÃ£o diferentes.");
                    return;
                }
                if ($scope.isRepresentante) {
                    var camposComErro;
                    if (!$scope.formPessoa.$valid) {
                        camposComErro = [];
                        var errors = $scope.formPessoa.$error.required || [];
                        for (var i = 0; i < errors.length; i++) {
                            camposComErro.push(errors[i].$name);
                        }
                        camposComErro = camposComErro.join(", ");
                        $rootScope.alert("Os campos seguintes sÃ£o obrigatÃ³rios: " + camposComErro);
                        return;
                    }
                }
                if ($scope.isPessoaFisica()) {
                    var requisicaoCadastro, pessoa, pessoaFisica = {
                        isRepresentante: $scope.isRepresentante,
                        dataNascimento: informacoes.dataNascimento,
                        nomeMae: informacoes.nomeMae
                    };
                    if (!$scope.isRepresentante) {
                        pessoa = {
                            nome: informacoes.nomeCompleto,
                            cpfCnpj: informacoes.cpfCnpj,
                            email: informacoes.email,
                            telefone: informacoes.telefone,
                            celular: informacoes.celular
                        };
                        if ($scope.isRepresentanteLegal) {
                            pessoa.cpfCnpj = informacoes.cpf;
                            pessoa.nome = informacoes.nome;
                        }
                        requisicaoCadastro = centralService.cadastrarPessoaFisica(pessoa, pessoaFisica, null, informacoes.senha, $routeParams.hash);
                    } else {
                        pessoa = {
                            nome: informacoes.nome,
                            cpfCnpj: informacoes.cpf,
                            email: informacoes.email,
                            telefone: informacoes.telefone,
                            celular: informacoes.celular
                        };
                        var representante = {
                            id: $routeParams.idRepresentante,
                            endereco: $scope.endereco
                        };
                        requisicaoCadastro = centralService.cadastrarPessoaFisica(pessoa, pessoaFisica, representante, informacoes.senha, $routeParams.hash);
                    }
                    requisicaoCadastro.success(function(response) {
                        sucesso(response, "Cadastro realizado com sucesso!");
                    }).error(function(response) {
                        erro(response);
                    });
                } else {
                    centralService.cadastrarPessoaJuridica(informacoes.nomeCompleto, informacoes.cpfCnpj, informacoes.nomeFantasia, informacoes.email, informacoes.telefone, informacoes.celular, informacoes.senha, $routeParams.hash).success(function(response) {
                        sucesso(response, "Cadastro realizado com sucesso!");
                    }).error(function(response) {
                        erro(response);
                    });
                }
            };
            function sucesso(response, title) {
                if (response.status === "s") {
                    $location.search({});
                    $rootScope.alert(response.mensagem, "bg-success", title);
                    $location.path("/central/acesso");
                    return;
                }
                $rootScope.alert(response.mensagem);
            }
            function erro(response) {
                $rootScope.alert(response.mensagem);
            }
            $scope.carregarMunicipios = function() {
                municipiosService.list($scope.endereco.estado.id, function(response) {
                    $scope.municipios = response.dados;
                    if ($scope.endereco && $scope.endereco.municipio) {
                        $scope.endereco.municipio = _.find($scope.municipios, function(municipio) {
                            return municipio.id === $scope.endereco.municipio.id;
                        });
                    }
                }, function() {});
            };
            var carregarEstados = function() {
                estadosService.list(function(response) {
                    $scope.ufs = response.dados;
                    if ($scope.endereco && $scope.endereco.estado) {
                        $scope.endereco.estado = _.find($scope.ufs, function(uf) {
                            return uf.id === $scope.endereco.estado.id;
                        });
                        $scope.carregarMunicipios();
                    }
                }, function(mensagemErro) {
                    erro(mensagemErro);
                });
            };
            if ($routeParams.idImovelPessoa) {
                centralService.buscarInformacoesPessoa($routeParams.idImovelPessoa, $routeParams.hash).success(function(response) {
                    if (response.status === "s") {
                        $scope.informacoes = response.dados;
                        $scope.informacoes.email = $routeParams.email;
                        $scope.informacoes.cpfCnpj = $scope.informacoes.cpfCnpj.formatarCpfCnpj();
                        tipoPessoa = response.dados.tipoPessoa;
                    } else {
                        $location.search({});
                        $rootScope.alert(response.mensagem);
                        $location.path("/central/acesso");
                    }
                });
            } else if ($routeParams.idRepresentante) {
                $scope.isRepresentante = true;
                centralService.buscarInformacoesRepresentante($routeParams.idRepresentante, $routeParams.hash).success(function(response) {
                    if (response.status === "s") {
                        $scope.informacoes = response.dados;
                        $scope.informacoes.email = $routeParams.email;
                        $scope.informacoes.dataNascimento = response.dados.dataNascimento ? new Date(response.dados.dataNascimento).toLocaleDateString("pt-BR") : undefined;
                        $scope.informacoes.cpf = $scope.informacoes.cpf.formatarCpfCnpj();
                        $scope.endereco = response.dados.endereco;
                        if ($scope.endereco && $scope.endereco.municipio) {
                            $scope.endereco.estado = $scope.endereco.municipio.estado;
                        }
                        carregarEstados();
                        $scope.controleRepresentante = {
                            habilitarNome: !$scope.informacoes.nome,
                            habilitarNomeMae: !$scope.informacoes.nomeMae,
                            habilitarCPF: !$scope.informacoes.cpf,
                            habilitarDataNascimento: !$scope.informacoes.dataNascimento
                        };
                        tipoPessoa = response.dados.tipoPessoa;
                    } else {
                        $location.search({});
                        $rootScope.alert(response.mensagem);
                        $location.path("/central/acesso");
                    }
                });
            } else if ($routeParams.idRepresentanteLegal) {
                $scope.isRepresentanteLegal = true;
                centralService.buscarInformacoesRepresentanteLegal($routeParams.idRepresentanteLegal, $routeParams.hash).success(function(response) {
                    if (response.status === "s") {
                        $scope.informacoes = response.dados;
                        $scope.informacoes.email = $routeParams.email;
                        $scope.informacoes.dataNascimento = response.dados.dataNascimento ? new Date(response.dados.dataNascimento).toLocaleDateString("pt-BR") : undefined;
                        $scope.informacoes.cpf = $scope.informacoes.cpf.formatarCpfCnpj();
                        $scope.controleRepresentante = {
                            habilitarNome: !$scope.informacoes.nome,
                            habilitarNomeMae: !$scope.informacoes.nomeMae,
                            habilitarCPF: !$scope.informacoes.cpf,
                            habilitarDataNascimento: !$scope.informacoes.dataNascimento
                        };
                        tipoPessoa = response.dados.tipoPessoa;
                    } else {
                        $location.search({});
                        $rootScope.alert(response.mensagem);
                        $location.path("/central/acesso");
                    }
                });
            }
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("HomeCtrl", [ "$scope", "$location", "pesquisaSiteService", function($scope, $location, pesquisaSiteService) {
            $("#view").removeClass("container main-container");
            $(document).ready(function() {
                $("#redes-sociais-footer").removeClass("exibir-redes-sociais");
            });
            $scope.pesquisa = {
                filtroPesquisa: ""
            };
            pesquisaSiteService.buscarOpcoesPesquisa(function(response) {
                $scope.opcoesBusca = response;
            });
            pesquisaSiteService.listMaisBuscados(function(response) {
                $scope.maisBuscados = response;
            });
            $scope.redirecionar = function(item) {
                pesquisaSiteService.redirecionar(item);
                pesquisaSiteService.incrementarPesquisaRealizada(item.id);
            };
            $scope.pesquisar = function() {
                $location.path("/busca").search({
                    termoPesquisado: $scope.pesquisa.filtroPesquisa
                });
            };
        } ]);
    })();
    angular.module("SICAR").directive("enterClick", [ "$timeout", function($timeout) {
        return function(scope, element, attrs) {
            element.bind("keydown keypress", function(event) {
                if (event.which === 13) {
                    var target = $(event.target);
                    $(target).trigger("click");
                }
            });
        };
    } ]).directive("ngEnter", function() {
        return function(scope, element, attrs) {
            element.bind("keydown keypress", function(event) {
                if (event.which === 13) {
                    scope.$apply(function() {
                        scope.$eval(attrs.ngEnter);
                    });
                    event.preventDefault();
                }
            });
        };
    });
    (function($) {
        var LoadingUtil = {};
        var countServices = 0;
        LoadingUtil.show = function(data, headersGetter) {
            $.blockUI({
                message: '<img src="img/loading.gif"/>',
                baseZ: 1e4,
                css: {
                    border: "none",
                    backgroundColor: "transparent",
                    top: "50%",
                    left: "50%",
                    marginTop: "-51px",
                    marginLeft: "-51px",
                    width: "102px"
                }
            });
            return data;
        };
        LoadingUtil.hide = function() {
            $.unblockUI();
        };
        exports.LoadingUtil = LoadingUtil;
    })(jQuery);
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("LoginCtrl", [ "$scope", "$rootScope", "$MD5", "$http", "config", function($scope, $rootScope, $MD5, $http, config) {
            $scope.isPopoverOpen = false;
            $scope.exibirLogin = function() {
                $rootScope.$broadcast("clicouEntrarLogin");
                $scope.isPopoverOpen = true;
            };
            var _id = null;
            $scope.requestInterno = function(__event) {
                var user = {
                    usuario: $scope.loginInterno,
                    password: $scope.passwordInterno
                };
                $scope.requestLogin(__event, user);
                $scope.isPopoverOpen = false;
            };
            $scope.requestLogin = function(__event, user, cenario) {
                var parameter;
                cenario = cenario || "I";
                if (!user.usuario || !user.password) {
                    $rootScope.alert("UsuÃ¡rio e Senha sÃ£o obrigatÃ³rios!");
                } else {
                    parameter = "usuario=" + user.usuario + "&senha=" + $MD5(user.password) + "&cenario=" + cenario;
                    $http({
                        url: "/intranet/autenticacao/login",
                        method: "POST",
                        data: parameter,
                        headers: {
                            "Content-Type": "application/x-www-form-urlencoded"
                        }
                    }).success(function(response) {
                        if (response.status === "s") {
                            if (response.dados.user.hasOwnProperty("indicadorTrocarSenha") && response.dados.user.indicadorTrocarSenha) {
                                _id = response.dados.user.id;
                                $scope.senha.senhaAntiga = null;
                                $scope.senha.novaSenha = null;
                                $scope.senha.confirmacaoNovaSenha = null;
                                $("#modalSenha").modal();
                            } else {
                                if (response.dados.instituicoesEPerfis && response.dados.instituicoesEPerfis instanceof Array && response.dados.instituicoesEPerfis.length > 0) {
                                    $scope.instituicoes = response.dados.instituicoesEPerfis;
                                    $scope.instituicao = $scope.instituicoes[0];
                                    $scope.instituicaoChangeHandler();
                                    $("#modalPerfil").modal();
                                } else {
                                    if (response.dados.hasOwnProperty("profile") && response.dados.profile) {
                                        window.location.href = config.BASE_URL + "/intranet";
                                    } else {
                                        _id = null;
                                        $scope.instituicoes = null;
                                        $rootScope.alert("O serviÃ§o de autenticaÃ§Ã£o se comportou de maneira inesperada. Tente efetuar login novamente.");
                                    }
                                }
                            }
                        } else {
                            $scope.loginInterno = undefined;
                            $scope.passwordInterno = undefined;
                            $rootScope.alert(response.mensagem);
                        }
                    }).error(function(__response) {
                        $rootScope.alert(__response.mensagem);
                    });
                }
            };
            $scope.instituicaoChangeHandler = function() {
                $scope.perfilInstituicao = $scope.instituicao.perfisInstituicao[0];
                var opcoesPerfis = [];
                var grupo;
                for (var i = 0; i < $scope.instituicao.perfisInstituicao.length; i++) {
                    if (!grupo || grupo.length % 4 === 0) {
                        grupo = [];
                        opcoesPerfis.push(grupo);
                    }
                    grupo.push($scope.instituicao.perfisInstituicao[i]);
                }
                $scope.opcoesPerfis = opcoesPerfis;
            };
            $scope.selecionarPerfilInstituicao = function(perfilInstituicao) {
                $scope.perfilInstituicao = perfilInstituicao;
            };
            $scope.efetuarLoginIntranet = function() {
                if (!$scope.perfilInstituicao) {
                    $rootScope.alert("O perfil nÃ£o foi selecionado.");
                    return;
                }
                var parameter = "idPerfilInstituicao=" + $scope.perfilInstituicao.id;
                $http({
                    url: "/intranet/autenticacao/perfil",
                    method: "POST",
                    data: parameter,
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                }).success(function(__response) {
                    if (__response.status === "s") {
                        if (_id == $scope.idExterno) window.location = config.BASE_URL + "/intranet/centralMensagens"; else window.location = config.BASE_URL + "/intranet";
                    } else {
                        $rootScope.alert(__response.mensagem);
                    }
                });
            };
            $scope.senha = {
                senhaAntiga: null,
                novaSenha: null,
                confirmacaoNovaSenha: null
            };
            $rootScope.$on("abrirModalTrocarSenha", function(event, idUsuario, usuario, senha) {
                _id = idUsuario;
                $scope.passwordInterno = senha;
                $scope.loginInterno = usuario;
                $("#modalSenha").modal();
            });
            $scope.requestPasswordLogin = function(__event) {
                $scope.isPopoverOpen = false;
                if (!$scope.senha.senhaAntiga || !$scope.senha.novaSenha || !$scope.senha.confirmacaoNovaSenha) {
                    $rootScope.alert("Os trÃªs campos sÃ£o obrigatÃ³rios!");
                    return;
                }
                if ($scope.passwordInterno != $scope.senha.senhaAntiga) {
                    $rootScope.alert("A senha antiga nÃ£o confere!");
                    return;
                }
                if ($scope.senha.novaSenha.length < 6) {
                    $rootScope.alert("A nova senha deve possuir no mÃ­nimo 6 caracteres.");
                    return;
                }
                if ($scope.senha.novaSenha != $scope.senha.confirmacaoNovaSenha) {
                    $rootScope.alert("A nova senha sÃ£o confere com a confirmaÃ§Ã£o!");
                    return;
                }
                var parameter = "senhaAntiga=" + $MD5($scope.senha.senhaAntiga) + "&senhaNova=" + $MD5($scope.senha.novaSenha) + "&idUsuario=" + _id;
                $http({
                    url: "/intranet/usuario/trocarSenha",
                    method: "POST",
                    data: parameter,
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                }).success(function(__response) {
                    if (__response.status === "e") {
                        $rootScope.alert(__response.mensagem);
                    } else {
                        $scope.passwordInterno = $scope.senha.novaSenha;
                        $("#modalSenha").modal("hide");
                        var cenario = __response.dados && __response.dados.interno ? "I" : "E";
                        $scope.requestLogin(null, {
                            usuario: $scope.loginInterno,
                            password: $scope.passwordInterno
                        }, cenario);
                    }
                });
            };
            $scope.init = function() {
                $scope.idExterno = 2;
                $scope.obj = {};
            };
            $scope.init();
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("loginService", [ "$http", "config", "requestUtil", function($http, config, requestUtil) {
            var service = {};
            service.isLogged = function(successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/intranet/autenticacao/isLogged", successCallback, errorCallback);
            };
            return service;
        } ]);
    })();
    (function($) {
        var datepicker = function() {
            return function(scope, element, attrs) {
                element.attr("readonly", "true");
                var maxDate = attrs.maxdate || "0";
                element.datepicker({
                    dateFormat: "dd/mm/yy",
                    dayNames: [ "Domingo", "Segunda", "TerÃ§a", "Quarta", "Quinta", "Sexta", "SÃ¡bado" ],
                    dayNamesMin: [ "Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "SÃ¡b" ],
                    monthNames: [ "Janeiro", "Fevereiro", "MarÃ§o", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro" ],
                    monthNamesShort: [ "Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez" ],
                    nextText: ">>",
                    prevText: "<<",
                    changeMonth: true,
                    changeYear: true,
                    showOn: "focus",
                    showAnim: "slideDown",
                    maxDate: maxDate,
                    yearRange: "-150:+0",
                    onSelect: function() {
                        scope.$eval(attrs.ngModel + " = '" + $(element).val() + "'");
                        scope.$digest();
                    }
                });
            };
        };
        var somenteNumero = function(e, obj, isDecimal) {
            if ([ e.keyCode || e.which ] == 8) return true;
            if (isDecimal) {
                if ([ e.keyCode || e.which ] == 110 || [ e.keyCode || e.which ] == 188) {
                    var val = obj.value;
                    if (val.indexOf(",") > -1) {
                        if (e.preventDefault) e.preventDefault(); else e.returnValue = false;
                        return false;
                    }
                    return true;
                }
            }
            if ([ e.keyCode || e.which ] < 48 || [ e.keyCode || e.which ] > 57) if ([ e.keyCode || e.which ] < 96 | [ e.keyCode || e.which ] > 105) if (e.preventDefault) e.preventDefault(); else e.returnValue = false;
            return true;
        };
        var mascara = function(formato) {
            $.mask.definitions.h = "[A-Za-z]";
            $.mask.definitions.a = "[A-Za-z0-9]";
            return function(scope, element, attrs) {
                element.focus(function() {
                    if ($(element).val().length !== formato.length) {
                        scope.$eval(attrs.ngModel + " = ''");
                        scope.$digest();
                    }
                });
                element.mask(formato, {
                    placeholder: "  ",
                    completed: function() {
                        scope.$eval(attrs.ngModel + " = '" + $(element).val() + "'");
                        scope.$digest();
                    }
                });
            };
        };
        var telefone = function() {
            return {
                require: "ngModel",
                restrict: "A",
                link: function(scope, element, attrs, controller) {
                    controller.$parsers.push(function(value) {
                        var transformedValue = applyMask(value);
                        if (attrs.validate) validate(transformedValue);
                        return transformedValue;
                    });
                    controller.$formatters.push(function(value) {
                        var transformedValue = applyMask(value);
                        if (attrs.validate) validate(transformedValue);
                        return transformedValue;
                    });
                    element.change(function() {
                        var value = element.val();
                        scope.$apply(function() {
                            if (attrs.validate) validate(value);
                        });
                    });
                    element.focusin(function() {
                        limpaMascara();
                    });
                    element.focusout(function() {
                        limpaMascara();
                    });
                    function limpaMascara() {
                        if (element.val().length !== 13 && element.val().length !== 14) {
                            scope.$eval(attrs.ngModel + " = ''");
                            scope.$digest();
                        }
                    }
                    function validate(value) {
                        controller.$setValidity("telefone", !!value);
                    }
                    function applyMask(value) {
                        if (value === undefined || !value) return undefined;
                        var transformedValue = telefone(value);
                        transformedValue = transformedValue.substring(0, 51);
                        if (transformedValue != value) {
                            controller.$setViewValue(transformedValue);
                            controller.$render();
                        }
                        return transformedValue;
                    }
                    function telefone(__value) {
                        __value = __value.replace(/\D/g, "");
                        if (__value.length > 2) {
                            __value = __value.replace(/^(\d{2})(\d+)/g, "($1) $2");
                        }
                        return __value;
                    }
                }
            };
        };
        angular.module("mascaras", []).directive("data", function() {
            return mascara("99/99/9999");
        }).directive("cep", function() {
            return mascara("99999-999");
        }).directive("cpf", function() {
            return mascara("999.999.999-99");
        }).directive("cpfcnpj", function() {
            return mascara("99999999999999");
        }).directive("cnpj", function() {
            return mascara("99.999.999/9999-99");
        }).directive("telefone", function() {
            return telefone();
        }).directive("recibo", function() {
            $("input[recibo]").css("text-transform", "uppercase");
            return mascara("hh-9999999-aaaa.aaaa.aaaa.aaaa.aaaa.aaaa.aaaa.aaaa");
        }).directive("datepicker", function() {
            return datepicker();
        }).directive("decimal", function() {
            return function(scope, element, attrs) {
                $(element).keydown(function(event) {
                    var isDecimal = attrs.decimal.toUpperCase() === "SIM" ? true : false;
                    return somenteNumero(event, this, isDecimal);
                });
            };
        });
    })(jQuery);
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("MensagemAvisoCtrl", [ "$scope", "$rootScope", function($scope, $rootScope) {
            $scope.exibirAviso = true;
            $scope.$on("clicouEntrarLogin", function() {
                $scope.exibirAviso = !$scope.exibirAviso;
            });
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("ModalBaixarModuloCtrl", [ "$scope", "config", "$uibModalInstance", "osSelecionado", "osConfig", "linuxPackageType", function($scope, config, $uibModalInstance, osSelecionado, osConfig, linuxPackageType) {
            $scope.osSelecionado = osSelecionado;
            $scope.osConfig = osConfig;
            $scope.linuxPackageType = linuxPackageType;
            var getOS = function() {
                var name = $scope.osSelecionado;
                if (name == "Linux") {
                    name += "_" + $scope.linuxPackageType;
                }
                return name;
            };
            $scope.fechar = function() {
                $uibModalInstance.dismiss();
            };
            $scope.redirect = function() {
                $scope.fechar();
                location.href = "#/sobre?page=SICARnosEstados";
            };
            $scope.baixar = function() {
                var name = getOS();
                var osData = osConfig[name];
                if (osData) {
                    var url = config.BASE_URL + "/download/car/" + osData.value;
                    window.open(url, "_blank");
                }
            };
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("municipiosService", [ "$http", "config", "requestUtil", function($http, config, requestUtil) {
            var service = {};
            service.list = function(codigoUF, successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/municipios/" + codigoUF, successCallback, errorCallback);
            };
            return service;
        } ]);
    })();
    angular.module("SICAR").directive("numeroCar", function() {
        return {
            require: "ngModel",
            restrict: "A",
            link: function(scope, element, attrs, controller) {
                controller.$parsers.push(function(value) {
                    var transformedValue = applyMask(value);
                    validateValue(value);
                    return transformedValue;
                });
                controller.$formatters.push(function(value) {
                    var transformedValue = applyMask(value);
                    validateValue(value);
                    return transformedValue;
                });
                element.change(function() {
                    var value = element.val();
                    scope.$apply(function() {
                        validateValue(value);
                    });
                });
                function validateValue(value) {
                    controller.$setValidity("numeroCar", !value || validate(value));
                }
                function applyMask(value) {
                    if (value === undefined) return undefined;
                    var transformedValue = numeroCar(value);
                    if (transformedValue === undefined || transformedValue === null) return undefined;
                    transformedValue = transformedValue.substring(0, 50);
                    if (transformedValue != value) {
                        controller.$setViewValue(transformedValue);
                        controller.$render();
                    }
                    return transformedValue;
                }
                function numeroCar(value) {
                    if (value === undefined || value === null) return undefined;
                    value = value.toString().toUpperCase();
                    value = value.replace(/\-/g, "");
                    var estado = value.substring(0, 2);
                    var sequenciaNumeros = value.substring(2, 9);
                    var alfanumericos = value.substring(9, 41);
                    if (value.length < 3) {
                        estado = estado.replace(/[^A-Z]/g, "");
                        value = estado;
                    } else if (value.length < 10) {
                        sequenciaNumeros = sequenciaNumeros.replace(/\D/g, "");
                        value = estado + "-" + sequenciaNumeros;
                    } else if (value.length <= 43) {
                        alfanumericos = alfanumericos.replace(/\W/g, "");
                        value = estado + "-" + sequenciaNumeros + "-" + alfanumericos;
                    }
                    return value;
                }
                function validate(value) {
                    if (!value) return true;
                    value = value.toString();
                    if (value.length >= 43) return true;
                    return false;
                }
            }
        };
    });
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("pesquisaSiteService", [ "$http", "config", "requestUtil", "$location", function($http, config, requestUtil, $location) {
            var service = {};
            service.buscarOpcoesPesquisa = function(successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/opcoesPesquisa", successCallback, errorCallback);
            };
            service.listMaisBuscados = function(successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/opcoesPesquisaMaisBuscadas", successCallback, errorCallback);
            };
            service.redirecionar = function(item) {
                if (item.isForaSite && item.link) {
                    window.open(item.link, "_blank");
                }
                if (item.valorParametroUrl && item.parametroUrl) {
                    var objeto = {};
                    objeto[item.parametroUrl] = item.valorParametroUrl;
                    $location.path(item.link).search(objeto);
                } else {
                    $location.path(item.link);
                }
            };
            service.incrementarPesquisaRealizada = function(idOpcao, successCallback, errorCallback) {
                requestUtil.post(config.BASE_URL + "/opcoesPesquisa/" + idOpcao, null, successCallback, errorCallback, null, true);
            };
            return service;
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.factory("opcoesBuscaSite", [ "$location", function($location) {
            var factory = {};
            factory.lista = [ {
                opcao: "Sobre o CAR",
                pagina: "/sobre"
            }, {
                opcao: "O que Ã© o CAR?",
                pagina: "/sobre"
            }, {
                opcao: "Quais sÃ£o os benefÃ­cios do CAR?",
                pagina: "/sobre",
                valorParametroPagina: "beneficios",
                chaveParametroPagina: "page"
            }, {
                opcao: "O que Ã© o SICAR?",
                pagina: "/sobre",
                valorParametroPagina: "OQueEoSICAR",
                chaveParametroPagina: "page"
            }, {
                opcao: "SICAR nos estados",
                pagina: "/sobre",
                valorParametroPagina: "SICARnosEstados",
                chaveParametroPagina: "page"
            }, {
                opcao: "ConheÃ§a os mÃ³dulos do SICAR",
                pagina: "/sobre",
                valorParametroPagina: "modulosSicar",
                chaveParametroPagina: "page"
            }, {
                opcao: "MÃ³dulo de relatÃ³rios do SICAR",
                pagina: "/sobre",
                valorParametroPagina: "modulosSicar",
                chaveParametroPagina: "page"
            }, {
                opcao: "Qual o conceito de ProprietÃ¡rio/Possuidor?",
                pagina: "/sobre",
                valorParametroPagina: "proprietario/possuidor",
                chaveParametroPagina: "page"
            }, {
                opcao: "ObrigaÃ§Ãµes do proprietÃ¡rio/possuidor?",
                pagina: "/sobre",
                valorParametroPagina: "proprietario/possuidor",
                chaveParametroPagina: "page"
            }, {
                opcao: "O que sÃ£o OEMAs?",
                pagina: "/sobre",
                valorParametroPagina: "OEMAs",
                chaveParametroPagina: "page"
            }, {
                opcao: "Qual a responsabilidade das OEMAs?",
                pagina: "/sobre",
                valorParametroPagina: "OEMAs",
                chaveParametroPagina: "page"
            }, {
                opcao: "O que Ã© o SFB?",
                pagina: "/sobre",
                valorParametroPagina: "SFB",
                chaveParametroPagina: "page"
            }, {
                opcao: "Quais sÃ£o as etapas do CAR?",
                pagina: "/sobre",
                valorParametroPagina: "inscricaoCAR",
                chaveParametroPagina: "page"
            }, {
                opcao: "InformaÃ§Ãµes para realizar cadastro no CAR",
                pagina: "/sobre",
                valorParametroPagina: "inscricaoCAR",
                chaveParametroPagina: "page"
            }, {
                opcao: "Como usar o mÃ³dulo de cadastro do CAR?",
                pagina: "/sobre",
                valorParametroPagina: "inscricaoCAR",
                chaveParametroPagina: "page"
            }, {
                opcao: "Para que serve o protocolo do CAR?",
                pagina: "/sobre",
                valorParametroPagina: "inscricaoCAR",
                chaveParametroPagina: "page"
            }, {
                opcao: "Para que serve o recibo do CAR?",
                pagina: "/sobre",
                valorParametroPagina: "inscricaoCAR",
                chaveParametroPagina: "page"
            }, {
                opcao: "Como enviar meu arquivo .car?",
                pagina: "/sobre",
                valorParametroPagina: "inscricaoCAR",
                chaveParametroPagina: "page"
            }, {
                opcao: "Entenda a situaÃ§Ã£o de seu imÃ³vel rural",
                pagina: "/sobre",
                valorParametroPagina: "acompanhamento",
                chaveParametroPagina: "page"
            }, {
                opcao: "Para que serve a Central do ProprietÃ¡rio/Possuidor?",
                pagina: "/sobre",
                valorParametroPagina: "acompanhamento",
                chaveParametroPagina: "page"
            }, {
                opcao: "O que Ã© o PRA",
                pagina: "/sobre",
                valorParametroPagina: "regAmbiental",
                chaveParametroPagina: "page"
            }, {
                opcao: "O que Ã© o Programa de RegularizaÃ§ao Ambiental?",
                pagina: "/sobre",
                valorParametroPagina: "regAmbiental",
                chaveParametroPagina: "page"
            }, {
                opcao: 'O que sÃ£o "Ativos Floestais"?',
                pagina: "/sobre",
                valorParametroPagina: "negAtivosFlorestais",
                chaveParametroPagina: "page"
            }, {
                opcao: "NegociaÃ§Ã£o de reserva legal",
                pagina: "/sobre",
                valorParametroPagina: "negAtivosFlorestais",
                chaveParametroPagina: "page"
            }, {
                opcao: "ComÃ©rcio de reserva legal",
                pagina: "/sobre",
                valorParametroPagina: "negAtivosFlorestais",
                chaveParametroPagina: "page"
            }, {
                opcao: "Cota de reserva legal",
                pagina: "/sobre",
                valorParametroPagina: "negAtivosFlorestais",
                chaveParametroPagina: "page"
            }, {
                opcao: "O que Ã© servidÃ£o Ambiental",
                pagina: "/sobre",
                valorParametroPagina: "negAtivosFlorestais",
                chaveParametroPagina: "page"
            }, {
                opcao: "CompensaÃ§Ã£o de reserva legal",
                pagina: "/sobre",
                valorParametroPagina: "negAtivosFlorestais",
                chaveParametroPagina: "page"
            }, {
                opcao: "Onde baixar o mÃ³dulo de cadastro do CAR?",
                pagina: "/baixar"
            }, {
                opcao: "Onde envio meu arquivo .car?",
                pagina: "/enviar"
            }, {
                opcao: "Como retificar meu cadastro .car",
                pagina: "/retificar"
            }, {
                opcao: "RetificaÃ§Ã£o do .car",
                pagina: "/retificar"
            }, {
                opcao: "Consultar a situaÃ§Ã£o do meu imÃ³vel rural",
                pagina: "/consultar"
            }, {
                opcao: "Meu cadastro estÃ¡ ativo?",
                pagina: "/consultar"
            }, {
                opcao: "Meu cadastro estÃ¡ pendente. O que devo fazer?",
                pagina: "/consultar"
            }, {
                opcao: "Por que meu cadastro foi cancelado?",
                pagina: "/consultar"
            }, {
                opcao: "LegislaÃ§Ã£o do CAR",
                pagina: "/suporte",
                chaveParametroPagina: "subPagina",
                valorParametroPagina: "legislacao"
            }, {
                opcao: "Leis do CAR",
                pagina: "/suporte",
                chaveParametroPagina: "subPagina",
                valorParametroPagina: "legislacao"
            }, {
                opcao: "InformaÃ§Ãµes bÃ¡sicas",
                pagina: "/suporte"
            }, {
                opcao: "Acesso direto a central do proprietÃ¡rio/possuidor",
                pagina: "/central/acesso"
            }, {
                opcao: "O que Ã© o Sistema de Cadastro Ambiental Rural - SiCAR?",
                pagina: "/suporte",
                valorParametroPagina: "0",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "Como fazer o Cadastro Ambiental Rural - CAR?",
                pagina: "/suporte",
                valorParametroPagina: "1",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "Como recuperar o recibo de inscriÃ§Ã£o e senha na Central do ProprietÃ¡rio/Possuidor?",
                pagina: "/suporte",
                valorParametroPagina: "2",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "Como acesso a Central do ProprietÃ¡rio/Possuidor?",
                pagina: "/suporte",
                valorParametroPagina: "3",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "Como cancelar um Cadastro Ambiental Rural - CAR feito de maneira indevida?",
                pagina: "/suporte",
                valorParametroPagina: "4",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "Quais sÃ£o as sanÃ§Ãµes para a nÃ£o adesÃ£o ao Cadastro Ambiental Rural?",
                pagina: "/suporte",
                valorParametroPagina: "5",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "Quem pode fazer o Cadastro Ambiental Rural?",
                pagina: "/suporte",
                valorParametroPagina: "6",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "HÃ¡ custos para o proprietÃ¡rio em requerer a inscriÃ§Ã£o do imÃ³vel rural no Cadastro Ambiental Rural - CAR?",
                pagina: "/suporte",
                valorParametroPagina: "7",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "Qual Ã© o prazo para inscriÃ§Ã£o do imÃ³vel rural no Cadastro Ambiental Rural - CAR?",
                pagina: "/suporte",
                valorParametroPagina: "8",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "O que sÃ£o os Programas de RegularizaÃ§Ã£o Ambiental - PRA e quais os seus benefÃ­cios?",
                pagina: "/suporte",
                valorParametroPagina: "9",
                chaveParametroPagina: "pergunta"
            }, {
                opcao: "Manual do usuÃ¡rio do mÃ³dulo de Cadastro",
                pagina: "/suporte",
                chaveParametroPagina: "subPagina",
                valorParametroPagina: "manuaisUsuario"
            }, {
                opcao: "Contato dos orgÃ£os de meio ambiente",
                pagina: "/contatos"
            }, {
                opcao: "Contato das OEMAs",
                pagina: "/contatos"
            }, {
                opcao: "Email das OEMAs",
                pagina: "/contatos"
            }, {
                opcao: "EndereÃ§o das OEMAs",
                pagina: "/contatos"
            }, {
                opcao: "Telefone das OEMAs",
                pagina: "/contatos"
            }, {
                opcao: "Site das OEMAs",
                pagina: "/contatos"
            }, {
                opcao: "RESOLUÃ‡ÃƒO NÂº 4.529, DE 27 DE OUTUBRO DE 2016",
                isForaSite: true,
                link: "http://www.paranacooperativo.coop.br/ppc/images/Comunicacao/2016/noticias/10/28/cmn_I/cmn_I_28_10_2016.pdf"
            }, {
                opcao: "LEI NÂº 13.335, DE 14 DE SETEMBRO DE 2016",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_Ato2015-2018/2016/Lei/L13335.htm"
            }, {
                opcao: "LEI NÂº 13.295, DE 14 DE JUNHO DE 2016",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_Ato2015-2018/2016/Lei/L13295.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA NÂº 724, DE 4 DE MAIO DE 2016",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_Ato2015-2018/2016/Mpv/mpv724.htm"
            }, {
                opcao: "INSTRUÃ‡ÃƒO NORMATIVA NÂº 3, DE 18 DE DEZEMBRO DE 2014",
                isForaSite: true,
                link: "leis/IN_CAR_3.pdf"
            }, {
                opcao: "INSTRUÃ‡ÃƒO NORMATIVA NÂº 2, DE 5 DE MAIO DE 2014",
                isForaSite: true,
                link: "leis/IN_CAR.pdf"
            }, {
                opcao: "DECRETO NÂº 8.235, DE 5 DE MAIO DE 2014",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_Ato2011-2014/2014/Decreto/D8235.htm"
            }, {
                opcao: "LEI NÂº 12.727, DE 17 DE OUTUBRO DE 2012",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_ato2011-2014/2012/lei/L12727.htm"
            }, {
                opcao: "DECRETO NÂº 7.830, DE 17 DE OUTUBRO DE 2012",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_Ato2011-2014/2012/Decreto/D7830.htm"
            }, {
                opcao: "LEI NÂº 12.651, DE 25 DE MAIO DE 2012",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_ato2011-2014/2012/lei/l12651.htm"
            }, {
                opcao: "DECRETO NÂº 6.514, DE 22 DE JULHO DE 2008",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_ato2007-2010/2008/decreto/d6514.htm"
            }, {
                opcao: "LEI NÂº 11.428, DE 22 DE DEZEMBRO DE 2006",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_ato2004-2006/2006/lei/l11428.htm"
            }, {
                opcao: "LEI NÂº 11.284, DE 2 DE MARÃ‡O DE 2006",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/_ato2004-2006/2006/lei/l11284.htm"
            }, {
                opcao: "LEI NÂº 10.650, DE 16 DE ABRIL DE 2003",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/Leis/2003/L10.650.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA NÂº 2.166-67, DE 24 AGOSTO DE 2001",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/2166-67.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA NÂº 2.166-65, DE 28 JUNHO DE 2001",
                isForaSite: true,
                link: "https://www.planalto.gov.br/ccivil_03/mpv/2166-65.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA NÂº 2.080-58, DE 27 DEZEMBRO DE 2000",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/2080-58.htm"
            }, {
                opcao: "LEI NÂº 9.985, DE 18 DE JULHO DE 2000",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/2080-58.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA NÂº 1.956-44, DE 9 DEZEMBRO DE 1999",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1956-44.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA NÂº 1.885-38, DE 29 JUNHO DE 1999",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1736-32.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA NÂº 1.885-38, DE 29 JUNHO DE 1999",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1736-32.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA NÂº 1.736-32, DE 13 DE JANEIRO DE 1999",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1736-32.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA NÂº 1.736-31, DE 14 DEZEMBRO DE 1998",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1736-31.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA MEDIDA PROVISÃ“RIA NÂº 1.605-18, de DEZEMBRO DE 1997",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1605-18.htm"
            }, {
                opcao: "MEDIDA PROVISÃ“RIA MEDIDA PROVISÃ“RIA NÂº 1.511-1, DE 22 AGOSTO  DE 1996",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1511-1.htm"
            }, {
                opcao: "DECRETO NÂº 1.298, DE 27 DE OUTUBRO DE 1994",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/decreto/1990-1994/D1298.htm"
            }, {
                opcao: "DECRETO NÂº 1.282, DE 19 DE OUTUBRO DE 1994",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/decreto/1990-1994/D1282.htm"
            }, {
                opcao: "LEI NÂº 7.875, DE 13 DE NOVEMBRO DE 1989",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/leis/1989_1994/L7875.htm"
            }, {
                opcao: "LEI NÂº 7.803, DE 18 DE JULHO DE 1989",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/leis/L7803.htm"
            }, {
                opcao: "LEI NÂº 7.754, DE 14 DE ABRIL DE 1989",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/leis/L7754.htm"
            }, {
                opcao: "DECRETO NÂº 97.628, DE 10 DE ABRIL DE 1989",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/decreto/1980-1989/D97628.htm"
            }, {
                opcao: "DECRETO NÂº 97.635, DE 10 DE ABRIL DE 1989",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/decreto/1980-1989/D97635.htm"
            }, {
                opcao: "LEI NÂº 7.511, DE 7 DE JULHO DE 1986",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/leis/L7511.htm"
            }, {
                opcao: "LEI NÂº 6.535, DE 15 DE JUNHO DE 1978",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/leis/L6535.htm"
            }, {
                opcao: "LEI NÂº 5.870, DE 26 DE MARÃ‡O DE 1973",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/leis/1970-1979/L5870.htm"
            }, {
                opcao: "LEI NÂº 5.868, DE 12 DE DEZEMBRO DE 1972",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/leis/L5868.htm"
            }, {
                opcao: "LEI NÂº 4.771, DE 15 DE SETEMBRO DE 1965",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/leis/L4771.htm"
            }, {
                opcao: "DECRETO NÂº 23.793, DE 23 DE JANEIRO DE 1934",
                isForaSite: true,
                link: "http://www.planalto.gov.br/ccivil_03/decreto/1930-1949/d23793.htm"
            } ];
            factory.buscar = function(item) {
                if (item.isForaSite && item.link) {
                    window.open(item.link, "_blank");
                }
                if (item.valorParametroPagina && item.chaveParametroPagina) {
                    var objeto = {};
                    objeto[item.chaveParametroPagina] = item.valorParametroPagina;
                    $location.path(item.pagina).search(objeto);
                } else {
                    $location.path(item.pagina);
                }
            };
            return factory;
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("CentralPessoaFisicaCtrl", [ "$scope", "$rootScope", "$location", "$filter", "centralService", "config", function($scope, $rootScope, $location, $filter, centralService, config) {
            $scope.pessoa = {
                dataNascimento: ""
            };
            function init() {
                $("#datePicker").datetimepicker({
                    lang: "pt-BR",
                    timepicker: false,
                    inline: false,
                    maxDate: new Date(2099, 0, 0),
                    minDate: new Date(1850, 0, 0),
                    yearStart: 1850,
                    yearEnd: 2099,
                    format: "d/m/Y"
                });
                $("#datePicker").mask("99/99/9999");
                $("input#centralConfirmacaoEmail, input#centralEmail").bind({
                    copy: function(e) {
                        e.preventDefault();
                    },
                    paste: function(e) {
                        e.preventDefault();
                    },
                    cut: function(e) {
                        e.preventDefault();
                    }
                });
            }
            $scope.validaDataNascimento = function() {
                if ($scope.pessoa.dataNascimento !== undefined && $scope.pessoa.dataNascimento !== null && $scope.pessoa.dataNascimento !== "") {
                    var data = $scope.pessoa.dataNascimento.split("/");
                    if (parseInt(data[0], 10) > 31 || parseInt(data[1], 10) > 12) {
                        $rootScope.alert("A data digitada Ã© invÃ¡lida");
                    }
                }
            };
            $scope.codigoImovel = centralService.codigoImovel();
            $scope.respostas = centralService.respostas();
            $scope.perguntasVerificacao = centralService.perguntasVerificacao();
            var cpf = centralService.cpfCnpj();
            if (_(centralService.respostas()).isEmpty() || _(centralService.codigoImovel()).isEmpty()) {
                $location.path("/central/acesso");
            }
            $scope.enviarValidacao = function() {
                console.log($scope.pessoa);
                if ($scope.pessoa.email.toLowerCase() != $scope.pessoa.email) {
                    $rootScope.alert("O e-mail informado deve conter apenas letras minÃºsculas.");
                    return;
                }
                if (_($scope.pessoa.mae).isEmpty()) {
                    $rootScope.alert("O campo nome da mÃ£e do ProprietÃ¡rio / Possuidor Ã© obrigatÃ³rio.");
                    return;
                }
                if ($scope.pessoa.dataNascimento === undefined || $scope.pessoa.dataNascimento === null || $scope.pessoa.dataNascimento === "") {
                    $rootScope.alert("O campo data de nascimento do ProprietÃ¡rio / Possuidor Ã© obrigatÃ³rio.");
                    return;
                }
                if (_($scope.pessoa.email).isEmpty()) {
                    $rootScope.alert("O campo o e-mail do ProprietÃ¡rio / Possuidor Ã© obrigatÃ³rio.");
                    return;
                }
                if (!$scope.pessoa.email.isEmail()) {
                    $rootScope.alert("E-mail informado nÃ£o estÃ¡ no formato correto.");
                    return;
                }
                if (_($scope.pessoa.emailConfirmacao).isEmpty()) {
                    $rootScope.alert("O campo e-mail de confirmaÃ§Ã£o do ProprietÃ¡rio / Possuidor Ã© obrigatÃ³rio.");
                    return;
                }
                if ($scope.pessoa.email != $scope.pessoa.emailConfirmacao) {
                    $rootScope.alert("O e-mail digitado e o e-mail de confirmaÃ§Ã£o estÃ£o diferentes.");
                    return;
                }
                var pessoa = {
                    nomeMae: $scope.pessoa.mae,
                    cpf: cpf.replace(/[^0-9]/g, ""),
                    email: $scope.pessoa.email,
                    dataNascimento: $filter("date")($scope.pessoa.dataNascimento, "dd/MM/yyyy"),
                    codigoImovel: $scope.codigoImovel.replace(/[.]/g, ""),
                    isRepresentante: $scope.perguntasVerificacao.isRepresentante,
                    isRepresentanteLegal: $scope.perguntasVerificacao.isRepresentanteLegal,
                    cpfCnpjProprietario: $scope.perguntasVerificacao.cpfCnpjProprietario
                };
                centralService.validarPessoaFisica(pessoa).success(function(response) {
                    $rootScope.alert(response.mensagem, "bg-success");
                    $location.path("/central/acesso");
                }).error(function(response) {
                    if (response.dados && response.dados.usuarioBloqueado) $location.path("/central/acesso");
                    $rootScope.alert(response.mensagem);
                    return;
                });
            };
            init();
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("CentralPessoaJuridicaCtrl", [ "$scope", "$rootScope", "$location", "centralService", "estadosService", "municipiosService", "config", function($scope, $rootScope, $location, centralService, estadosService, municipiosService, config) {
            function init() {
                $("input#centralConfirmacaoEmail, input#centralEmail").bind({
                    copy: function(e) {
                        e.preventDefault();
                    },
                    paste: function(e) {
                        e.preventDefault();
                    },
                    cut: function(e) {
                        e.preventDefault();
                    }
                });
            }
            $scope.codigoImovel = centralService.codigoImovel();
            $scope.respostas = centralService.respostas();
            $scope.perguntasVerificacao = centralService.perguntasVerificacao();
            var cnpj = centralService.cpfCnpj();
            $scope.pessoa = {};
            estadosService.list(function(data) {
                $scope.estados = data.dados;
            });
            $scope.nomeUsuario = function() {
                var nome = "Pessoa JurÃ­dica";
                if ($scope.perguntasVerificacao) {
                    if ($scope.perguntasVerificacao.isRepresentante) {
                        return "Representante";
                    }
                    if ($scope.perguntasVerificacao.isRepresentanteLegal) {
                        return "Representante Legal";
                    }
                }
                return nome;
            };
            $scope.listaMunicipios = function() {
                municipiosService.list($scope.uf.id, function(data) {
                    $scope.municipios = data.dados;
                });
            };
            if (_(centralService.respostas()).isEmpty() || _(centralService.codigoImovel()).isEmpty()) {
                $location.path("/central/acesso");
            }
            $scope.enviarValidacao = function() {
                if ($scope.pessoa.email.toLowerCase() != $scope.pessoa.email) {
                    $rootScope.alert("O e-mail informado deve conter apenas letras minÃºsculas.");
                    return;
                }
                if (_($scope.pessoa.razao).isEmpty()) {
                    $rootScope.alert("O campo Nome / Razao Social do ProprietÃ¡rio / Possuidor Ã© obrigatÃ³rio.");
                    return;
                }
                if (_($scope.uf).isEmpty()) {
                    $rootScope.alert("O campo Estado (UF) do ImÃ³vel Ã© obrigatÃ³rio.");
                    return;
                }
                if (_($scope.municipio).isEmpty()) {
                    $rootScope.alert("O campo Municipio do ImÃ³vel Ã© obrigatÃ³rio.");
                    return;
                }
                if (_($scope.pessoa.email).isEmpty()) {
                    $rootScope.alert("O campo e-mail do ProprietÃ¡rio / Possuidor Ã© obrigatÃ³rio.");
                    return;
                }
                if (!$scope.pessoa.email.isEmail()) {
                    $rootScope.alert("E-mail informado nÃ£o estÃ¡ no formato correto.");
                    return;
                }
                if (_($scope.pessoa.emailConfirmacao).isEmpty()) {
                    $rootScope.alert("O campo e-mail de confirmaÃ§Ã£o do ProprietÃ¡rio / Possuidor Ã© obrigatÃ³rio.");
                    return;
                }
                if ($scope.pessoa.email != $scope.pessoa.emailConfirmacao) {
                    $rootScope.alert("O e-mail digitado e o e-mail de confirmaÃ§Ã£o estÃ£o diferentes.");
                    return;
                }
                var pessoa = {
                    cnpj: cnpj.replace(/[^0-9]/g, ""),
                    email: $scope.pessoa.email,
                    codigoImovel: $scope.codigoImovel.replace(/[.]/g, ""),
                    isRepresentante: $scope.perguntasVerificacao.isRepresentante,
                    isRepresentanteLegal: $scope.perguntasVerificacao.isRepresentanteLegal,
                    codigoMunicipioIbge: $scope.municipio,
                    nomeCompleto: $scope.pessoa.razao,
                    cpfCnpjProprietario: $scope.perguntasVerificacao.cpfCnpjProprietario
                };
                centralService.validarPessoaJuridica(pessoa).success(function(response) {
                    $rootScope.alert(response.mensagem, "bg-success");
                    $location.path("/central/acesso");
                }).error(function(response) {
                    $rootScope.alert(response.mensagem);
                    return;
                });
            };
            init();
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("requestUtil", [ "$http", "$rootScope", function($http, $rootScope) {
            var opts = {
                lines: 11,
                length: 0,
                width: 5,
                radius: 11,
                corners: 1,
                rotate: 0,
                direction: 1,
                color: "#008637",
                speed: .7,
                trail: 45,
                shadow: true,
                hwaccel: false,
                className: "spinner",
                zIndex: 2e9,
                top: "50%",
                left: "50%"
            };
            var service = {};
            var count = 0;
            var elementCount = {};
            var showLoading = function(element) {
                if (element) {
                    if (!elementCount[element]) elementCount[element] = {
                        count: 0
                    };
                    if (elementCount[element].count === 0) {
                        var target = document.getElementById(element);
                        elementCount[element].spinner = new Spinner(opts).spin(target);
                        target.style.opacity = "0.5";
                    }
                    elementCount[element].count++;
                } else {
                    if (count === 0) app.LoadingUtil.show();
                    count++;
                }
            };
            var hideLoading = function(element) {
                if (element) {
                    elementCount[element].count--;
                    if (elementCount[element].count === 0) {
                        elementCount[element].spinner.stop();
                        var target = document.getElementById(element);
                        if (target) {
                            target.style.opacity = "1";
                        }
                    }
                } else {
                    count--;
                    if (count === 0) app.LoadingUtil.hide();
                }
            };
            service.send = function(configObject, success, error, semLoading, element) {
                if (!semLoading) showLoading(element);
                return $http(configObject).success(function(data) {
                    if (!semLoading) hideLoading(element);
                    if (success) {
                        success.call(null, data);
                    }
                }).error(function(data) {
                    if (!semLoading) hideLoading(element);
                    if (!error) {
                        $rootScope.$broadcast("showMensagemEvent", data, "danger");
                    } else {
                        error.call(null, data);
                    }
                });
            };
            service.get = function(url, success, error, semLoading, element) {
                if (!semLoading) showLoading(element);
                return $http.get(url).success(function(data) {
                    if (!semLoading) hideLoading(element);
                    if (success) {
                        success.call(null, data);
                    }
                }).error(function(data) {
                    if (!semLoading) hideLoading(element);
                    if (!error) {
                        $rootScope.$broadcast("showMensagemEvent", data, "danger");
                    } else {
                        error.call(null, data);
                    }
                });
            };
            service.post = function(url, data, success, error, config, semLoading, element) {
                if (!semLoading) showLoading(element);
                return $http.post(url, data).success(function(data) {
                    if (!semLoading) hideLoading(element);
                    if (success) {
                        success.call(null, data);
                    }
                }).error(function(data) {
                    if (!semLoading) hideLoading(element);
                    if (!error) {
                        $rootScope.$broadcast("showMensagemEvent", data, "danger");
                    } else {
                        error.call(null, data);
                    }
                });
            };
            return service;
        } ]);
    })();
    angular.module("SICAR").directive("scrollToItem", function() {
        return {
            restrict: "A",
            scope: {
                scrollTo: "@"
            },
            link: function(scope, $elm, attr) {
                $elm.on("click", function() {
                    $("html,body").animate({
                        scrollTop: $(scope.scrollTo).offset().top - 145
                    }, "slow");
                });
            }
        };
    });
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("SobreCtrl", [ "$scope", "$location", function($scope, $location) {
            $scope.page = {
                current: "oQueCAR"
            };
            $scope.setPage = function(pageName) {
                $scope.page.current = pageName;
                openCorrectAccordion(pageName);
            };
            $scope.firstOpen = {
                status: false
            };
            $scope.secondOpen = {
                status: false
            };
            $scope.thirdOpen = {
                status: false
            };
            $scope.fourthOpen = {
                status: false
            };
            $scope.redirecionarAcessoCentral = function() {
                $location.path("/central/acesso");
            };
            $scope.init = function() {
                var actualPage = $location.search().page;
                $scope.setPage(actualPage);
                openCorrectAccordion(actualPage);
            };
            function openCorrectAccordion(actualPage) {
                switch (actualPage) {
                  case "oQueCAR":
                  case "beneficios":
                    $scope.firstOpen.status = true;
                    break;

                  case "OQueEoSICAR":
                  case "SICARnosEstados":
                  case "modulosSicar":
                    $scope.secondOpen.status = true;
                    break;

                  case "proprietario/possuidor":
                  case "OEMAs":
                  case "SFB":
                    $scope.thirdOpen.status = true;
                    break;

                  case "inscricaoCAR":
                  case "acompanhamento":
                  case "regAmbiental":
                  case "negAtivosFlorestais":
                    $scope.fourthOpen.status = true;
                    break;

                  default:
                    $scope.firstOpen.status = true;
                    $scope.setPage("oQueCAR");
                }
            }
        } ]);
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.controller("SuporteCtrl", [ "$scope", "$location", "config", "clipboard", function($scope, $location, config, clipboard) {
            $scope.page = {
                current: "inscricaoCar"
            };
            $scope.firstPanel = {
                open: true
            };
            var firstOpenPages = [ "inscricaoCar", "retificacaoCar", "regularizacao", "compensacaoReserva", "beneficios", "dados", "atendimento" ];
            $scope.pergunta = {
                selecionada: null
            };
            $scope.isOpen = [];
            $scope.faq = {
                perguntas: [ {
                    id: "0",
                    categoria: "inscricaoCar",
                    pergunta: "O que Ã© o Cadastro Ambiental Rural â€“ CAR e qual Ã© a sua finalidade?",
                    resposta: "<p>O Cadastro Ambiental Rural â€“ CAR Ã© um registro pÃºblico eletrÃ´nico nacional, obrigatÃ³rio para todos os imÃ³veis rurais, com a finalidade de integrar as informaÃ§Ãµes ambientais das propriedades e posses rurais, compondo base de dados para controle, monitoramento, planejamento ambiental e econÃ´mico e combate ao desmatamento. Foi criado pela Lei 12.651/2012, art. 29.</p>"
                }, {
                    id: "1",
                    categoria: "inscricaoCar",
                    pergunta: "O que Ã© o Sistema de Cadastro Ambiental Rural - SICAR?",
                    resposta: "<p>O Sistema de Cadastro Ambiental Rural â€“ SICAR Ã© o responsÃ¡vel por emitir o Recibo de InscriÃ§Ã£o do imÃ³vel rural no CAR, confirmando a efetivaÃ§Ã£o do cadastramento e o envio da documentaÃ§Ã£o exigida para a anÃ¡lise da localizaÃ§Ã£o da Ã¡rea de Reserva Legal. Definido como Sistema eletrÃ´nico de Ã¢mbito nacional destinado ao gerenciamento de informaÃ§Ãµes ambientais dos imÃ³veis rurais de todo o PaÃ­s. Essas informaÃ§Ãµes destinam-se a subsidiar polÃ­ticas, programas, projetos e atividades de controle, monitoramento, planejamento ambiental e econÃ´mico e combate ao desmatamento.</p><p>Foi criado por meio do Decreto nÂ° 7.830/2012, art. 3Âº, com os seguintes objetivos:</p><ol><li>receber, gerenciar e integrar os dados do CAR de todos os entes federativos</li><li>cadastrar e controlar as informaÃ§Ãµes dos imÃ³veis rurais, referentes a seu perÃ­metro e localizaÃ§Ã£o, aos remanescentes de vegetaÃ§Ã£o nativa, Ã s Ã¡reas de interesse social, Ã s Ã¡reas de utilidade pÃºblica, Ã s Ãreas de PreservaÃ§Ã£o Permanente, Ã s Ãreas de Uso Restrito, Ã s Ã¡reas consolidadas e Ã s Reservas Legais;</li><li>monitorar a manutenÃ§Ã£o, a recomposiÃ§Ã£o, a regeneraÃ§Ã£o, a compensaÃ§Ã£o e a supressÃ£o da vegetaÃ§Ã£o nativa e da cobertura vegetal nas Ã¡reas de PreservaÃ§Ã£o Permanente, de Uso Restrito, e de Reserva Legal, no interior dos imÃ³veis rurais;</li><li>promover o planejamento ambiental e econÃ´mico do uso do solo e conservaÃ§Ã£o ambiental no territÃ³rio nacional; e</li><li>disponibilizar informaÃ§Ãµes de natureza pÃºblica sobre a regularizaÃ§Ã£o ambiental dos imÃ³veis rurais em territÃ³rio nacional, na Internet.</li></ol>"
                }, {
                    id: "2",
                    categoria: "inscricaoCar",
                    pergunta: "Quais sÃ£o as situaÃ§Ãµes em que os filtros automÃ¡ticos do que Sistema de Cadastro Ambiental Rural â€“ SICAR nÃ£o permite finalizaÃ§Ã£o da inscriÃ§Ã£o do imÃ³vel rural no CAR?",
                    resposta: "<p>O SICAR dispÃµe de filtros automÃ¡ticos para recebimento dos cadastros e finalizaÃ§Ã£o do preenchimento do MÃ³dulo de Cadastro, que tem como objetivo estabelecer critÃ©rios mÃ­nimos para elaboraÃ§Ã£o do cadastro e inscriÃ§Ã£o no CAR, sendo eles:</p><ol><li>Limite Brasil: TolerÃ¢ncia de atÃ© 1 km de distÃ¢ncia do imÃ³vel em relaÃ§Ã£o aos limites do Brasil, conforme base do IBGE;</li><li>Limites de Estados: A inscriÃ§Ã£o deve ser feita no estado que contenha mais de 50% da Ã¡rea do imÃ³vel em hectares, segundo base de limites estaduais do IBGE;</li><li>Limites de municÃ­pio: O municÃ­pio que imÃ³vel for declarado deve conter ao menos parte do perÃ­metro do imÃ³vel;</li><li>ImÃ³vel sobreposto acima de 30% em ImÃ³vel Rural jÃ¡ declarado com mesmos CPFs/CNPJs: Caso o cadastro seja declarado e jÃ¡ exista um imÃ³vel na base do SICAR com as mesmas pessoas fÃ­sicas ou jurÃ­dicas e a sobreposiÃ§Ã£o seja igual ou maior Ã  30%, serÃ¡ considerado como tentativa de cadastro do mesmo imÃ³vel, o que nÃ£o Ã© permitido pelo SICAR;</li><li>DivergÃªncia entre Ã¡rea do imÃ³vel rural vetorizada e declarada em documento:<ul><li>Para ImÃ³veis rurais atÃ© 4 mÃ³dulos fiscais:<ul><li><p>NÃ£o Ã© gerado o arquivo â€œ.carâ€ se a vetorizaÃ§Ã£o for divergente 100% da Ã¡rea declarada em documento. Para isso o sistema faz duas checagens:</p><ol><li>NÃ£o gera â€œ.carâ€ se a vetorizaÃ§Ã£o Ã© maior ou igual ao dobro da Ã¡rea declarada. Ex: Ãrea total em Documento = 50ha e VetorizaÃ§Ã£o = 100ha</li><li>NÃ£o gera â€œ.carâ€ se a declaraÃ§Ã£o em documento maior ou igual ao dobro da Ã¡rea vetorizada. Ex: Ãrea total em Documento = 100ha e VetorizaÃ§Ã£o = 50ha</li></ol></li></ul></li><li>Para ImÃ³veis rurais acima de 4 mÃ³dulos fiscais:<ul><li><p>NÃ£o Ã© gerado â€œ.carâ€ se a vetorizaÃ§Ã£o for divergente 50% da Ã¡rea declarada em documento. Para isso o sistema faz duas checagens:</p><ol><li>NÃ£o gera o arquivo â€œ.carâ€ se a vetorizaÃ§Ã£o for maior ou igual 1,5 vezes que a Ã¡rea declarada. Ex: Ãrea total em Documento = 100ha e VetorizaÃ§Ã£o = 150ha</li><li>NÃ£o gera â€œ.carâ€ se a declaraÃ§Ã£o for maior ou igual 1,5 vezes maior que a Ã¡rea vetorizada. Ex: Ãrea total em Documento = 150ha e VetorizaÃ§Ã£o = 100ha</li></ol></li></ul></li></ul></li></ol><p>Envio para o SICAR nacional de â€œ.carâ€ gerado em MÃ³dulo de Cadastro do SICAR com receptor estadual: NÃ£o Ã© permitido que o cadastro efetuado em MÃ³dulo de Cadastro do SICAR com receptor estadual seja enviado por meio da pÃ¡gina do SICAR nacional <a href='http://www.car.gov.br'>(www.car.gov.br)</a>, neste caso o envio do â€œ.carâ€ deve ser feito no sÃ­tio eletrÃ´nico do SICAR estadual.</p>"
                }, {
                    id: "3",
                    categoria: "inscricaoCar",
                    pergunta: "Quais sÃ£o os casos em que os filtros automÃ¡ticos do Sistema de Cadastro Ambiental Rural â€“ SICAR alteram a situaÃ§Ã£o do imÃ³vel para pendente?",
                    resposta: "<p>O SICAR dispÃµe de filtros automÃ¡ticos que tem como objetivo verificar a existÃªncia de pendÃªncias relativas Ã  sobreposiÃ§Ã£o de imÃ³veis rurais com unidades de conservaÃ§Ã£o, terras indÃ­genas e Ã¡reas embargadas pelo IBAMA.  Caso o imÃ³vel rural inscrito no CAR apresente um ou mais casos ele terÃ¡ sua situaÃ§Ã£o alterada para â€œPendenteâ€, conforme as regras abaixo:</p><ol><li>Terras IndÃ­genas: O imÃ³vel rural ficarÃ¡ â€œPendenteâ€ caso esteja totalmente ou parcialmente sobreposto com Terras IndÃ­genas homologadas constates na base de dados da FUNAI.</li><li>Unidades de ConservaÃ§Ã£o: O imÃ³vel rural ficarÃ¡ â€œPendenteâ€ caso esteja totalmente ou parcialmente sobreposto com Unidades de ConservaÃ§Ã£o dos tipos Reserva de Fauna (Reserva de Fauna), REBIO (Reserva BiolÃ³gica), PARNA (Parque Nacional) e ESEC (EstaÃ§Ã£o EcolÃ³gica) constantes na base de dados do CNUC (Cadastro Nacional de Unidades de ConservaÃ§Ã£o), conforme as seguintes regras de tolerÃ¢ncia:<ul><li>10% para ImÃ³veis rurais pequenos (atÃ© 4 mÃ³dulos fiscais);</li><li>4% para ImÃ³veis rurais mÃ©dios (maiores que 4 atÃ© 15 mÃ³dulos fiscais);</li><li>3% para ImÃ³veis rurais grandes (maiores que 4 atÃ© 15 mÃ³dulos fiscais) </li></ul></li><li>Ãreas embargadas pelos Ã³rgÃ£os competentes: O imÃ³vel rural ficarÃ¡ â€œPendenteâ€ caso esteja totalmente ou parcialmente sobreposto com Ã¡reas embargadas constantes no sistema de Ã¡reas embargadas do IBAMA.</li></ol><p>A consulta em relaÃ§Ã£o Ã s sobreposiÃ§Ãµes e a situaÃ§Ã£o da inscriÃ§Ã£o do imÃ³vel rural no CAR podem ser obtidos no Demonstrativo da SituaÃ§Ã£o do CAR, obtido por meio da consulta pÃºblica disponÃ­vel em <a href='www.car.gov.br'>www.car.gov.br</a>, utilizando-se do nÃºmero do recibo ou do protocolo de inscriÃ§Ã£o, ou na Central do ProprietÃ¡rio/possuidor. Caso o imÃ³vel esteja pendente por conta de uma ou mais sobreposiÃ§Ãµes ele poderÃ¡ proceder, na Central do ProprietÃ¡rio/possuidor, com a retificaÃ§Ã£o ou envio de documentaÃ§Ã£o conforme o caso.</p>"
                }, {
                    id: "4",
                    categoria: "inscricaoCar",
                    pergunta: "Qual Ã© o prazo para inscriÃ§Ã£o do imÃ³vel rural no CAR?",
                    resposta: "<p>Segundo Â§ 3Âº do artigo 29 da Lei 12.651/2012, alterado pela Lei 13.295/2016, a inscriÃ§Ã£o no CAR deverÃ¡ ser feita atÃ© 31 de dezembro de 2017, e apÃ³s essa data, as instituiÃ§Ãµes financeiras sÃ³ concederÃ£o crÃ©dito agrÃ­cola, em qualquer de suas modalidades, para proprietÃ¡rios de imÃ³veis rurais que estejam inscritos no CAR</p>"
                }, {
                    id: "5",
                    categoria: "inscricaoCar",
                    pergunta: "Como fazer a inscriÃ§Ã£o do imÃ³vel rural no CAR?",
                    resposta: "<p>A inscriÃ§Ã£o no CAR Ã© realizada por meio de sistema eletrÃ´nico e deverÃ¡ ser feita junto ao Ã³rgÃ£o estadual competente, na Unidade da FederaÃ§Ã£o (UF) em que se localiza o imÃ³vel rural. Estados e Distrito Federal disponibilizam, na internet, endereÃ§o eletrÃ´nico para interface de programa junto ao SICAR, destinado Ã  inscriÃ§Ã£o, Ã  consulta e ao acompanhamento da situaÃ§Ã£o da regularizaÃ§Ã£o ambiental dos imÃ³veis rurais. Esses endereÃ§os podem ser acessados por meio do SICAR, no link <a href='http://car.gov.br/#/baixar'>http://car.gov.br/#/baixar</a>, bastando selecionar a UF em que se localiza o imÃ³vel rural e seguir as instruÃ§Ãµes disponÃ­veis. Ã‰ importante a correta seleÃ§Ã£o da UF, pois existem Estados com Sistemas prÃ³prios ou SICAR com receptor estadual, e sÃ³ recebem os cadastros preenchidos por meio do seu respectivo Sistema. ApÃ³s o download do MÃ³dulo de Cadastro, proceda a instalaÃ§Ã£o do aplicativo.</p><p>InformaÃ§Ãµes detalhadas sobre o correto preenchimento da declaraÃ§Ã£o do imÃ³vel rural no CAR estÃ£o disponÃ­veis no Manual do UsuÃ¡rio, acessÃ­vel sÃ­tio eletrÃ´nico do SICAR.</p><p>Nos entes federativos que utilizam a versÃ£o padrÃ£o do MÃ³dulo de Cadastro do SICAR, as declaraÃ§Ãµes devem ser preenchidas e gravadas gerando o arquivo â€œ.carâ€ a ser enviado ao SICAR. Ao final deste procedimento obtÃªm-se o Protocolo de preenchimento. O envio do arquivo â€œ.carâ€ depende de acesso Ã  internet, e poderÃ¡ ser feito no MÃ³dulo de Cadastro do SICAR, botÃ£o â€œENVIARâ€, ou no SICAR, aba â€œENVIARâ€, link <a href='http://car.gov.br/#/enviar'>http://car.gov.br/#/enviar</a>. O sucesso no envio Ã© confirmado pela emissÃ£o do â€œRecibo de InscriÃ§Ã£o do ImÃ³vel Rural no CARâ€, documento comprobatÃ³rio da efetivaÃ§Ã£o da inscriÃ§Ã£o no SICAR. Nos casos de estados que utilizam sistemas prÃ³prios ou SICAR com receptor estadual, a emissÃ£o do Recibo nÃ£o ocorrerÃ¡ imediatamente apÃ³s o envio do arquivo â€œ.carâ€ pelo usuÃ¡rio, pois Ã© necessÃ¡rio haver a integraÃ§Ã£o dos dados estaduais com a base do SICAR.</p><p>Caso existam dÃºvidas relativas aos procedimentos de inscriÃ§Ã£o e obtenÃ§Ã£o do recibo, solicite ajuda ao Ã³rgÃ£o estadual competente em que se localiza o imÃ³vel rural (link para a pergunta anterior). Contatos disponÃ­veis em <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "6",
                    categoria: "inscricaoCar",
                    pergunta: "Para que serve a inscriÃ§Ã£o do imÃ³vel rural no CAR?",
                    resposta: "<p>A inscriÃ§Ã£o do imÃ³vel rural no CAR serve para:</p><ul><li>cumprir da obrigatoriedade de declaraÃ§Ã£o e registro das informaÃ§Ãµes ambientais de todos os imÃ³veis rurais no Brasil e emissÃ£o do â€œRecibo de InscriÃ§Ã£o do ImÃ³vel Rural no CARâ€;</li><li>registrar a Ã¡rea de Reserva Legal no Ã³rgÃ£o ambiental competente, e como requisito para aprovaÃ§Ã£o da sua localizaÃ§Ã£o;</li><li>proceder Ã  regularizaÃ§Ã£o ambiental mediante adesÃ£o aos Programas de RegularizaÃ§Ã£o Ambiental dos Estados e do Distrito Federal â€“ PRA;</li><li>acessar aos programas de apoio governamental;</li><li>requisitar autorizaÃ§Ã£o da prÃ¡tica de aquicultura e infraestrutura a ela associada nos imÃ³veis rurais com atÃ© 15 (quinze) mÃ³dulos rurais, localizados em Ã¡reas de preservaÃ§Ã£o permanente;</li><li>requisitar autorizaÃ§Ã£o de supressÃ£o de floresta ou outras formas de vegetaÃ§Ã£o nativa no imÃ³vel rural;</li><li>requisitar o cÃ´mputo das Ãreas de PreservaÃ§Ã£o Permanente no cÃ¡lculo da Reserva Legal do imÃ³vel;</li><li>requisitar autorizaÃ§Ã£o da exploraÃ§Ã£o econÃ´mica da Reserva Legal mediante manejo sustentÃ¡vel;</li><li>requisitar a constituiÃ§Ã£o de servidÃ£o ambiental e Cota de Reserva Ambiental no imÃ³vel rural, e para acessar os mecanismos de compensaÃ§Ã£o da Reserva Legal;</li><li>requisitar autorizaÃ§Ã£o de intervenÃ§Ã£o e supressÃ£o de vegetaÃ§Ã£o em Ãreas de PreservaÃ§Ã£o Permanente e de Reserva Legal para atividades de baixo impacto ambiental; e</li><li>requisitar a autorizaÃ§Ã£o da continuidade das atividades agrossilvipastoris, de ecoturismo e de turismo rural em Ã¡reas rurais consolidadas atÃ© em 22 de julho de 2008 localizadas em Ãreas de PreservaÃ§Ã£o Permanente e Reserva Legal; e para</li><li>acessar o credito agrÃ­cola, em qualquer de suas modalidades, apÃ³s 31 de dezembro de 2017.</li></ul>"
                }, {
                    id: "7",
                    categoria: "inscricaoCar",
                    pergunta: "Quem deve estar inscrito no CAR?",
                    resposta: "<p>A inscriÃ§Ã£o no CAR Ã© obrigatÃ³ria para todos os imÃ³veis rurais do paÃ­s, inclusive Ã¡reas e territÃ³rios de uso coletivo, tituladas ou concedidas a povos ou comunidades tradicionais e imÃ³veis rurais de Programa de Reforma AgrÃ¡ria caracterizados como assentamento, independente da forma de titulaÃ§Ã£o e da exploraÃ§Ã£o do imÃ³vel rural.</p>"
                }, {
                    id: "8",
                    categoria: "inscricaoCar",
                    pergunta: "Quem pode fazer a inscriÃ§Ã£o no CAR?",
                    resposta: "<p>A inscriÃ§Ã£o no CAR poderÃ¡ ser feita por um cadastrante, pelo prÃ³prio proprietÃ¡rio / possuidor do imÃ³vel rural ou por um representante legal, pessoa fÃ­sica que estarÃ¡ habilitada pelo proprietÃ¡rio / possuidor a representÃ¡-lo em todas as etapas do CAR.</p><p>As Ã¡reas e territÃ³rios de uso coletivo, tituladas ou concedidas a povos ou comunidades tradicionais deverÃ£o ser inscritas no CAR pelo Ã³rgÃ£o ou instituiÃ§Ã£o competente pela sua gestÃ£o ou pela entidade representativa proprietÃ¡ria ou concessionÃ¡ria dos imÃ³veis rurais.</p><p>Ã‰ de responsabilidade do Ã³rgÃ£o fundiÃ¡rio competente a inscriÃ§Ã£o no CAR dos assentamentos de Reforma AgrÃ¡ria. Nos casos da inscriÃ§Ã£o individualizada dos lotes contidos nos assentamentos de Reforma AgrÃ¡ria, Ã© opcional fazÃª-lo por seus prÃ³prios meios ou contando com o apoio do Ã³rgÃ£o fundiÃ¡rio competente, para proceder os respectivos cadastros no CAR.</p>"
                }, {
                    id: "9",
                    categoria: "inscricaoCar",
                    pergunta: "Quem Ã© o responsÃ¡vel pelas informaÃ§Ãµes declaradas no CAR?",
                    resposta: "<p>As informaÃ§Ãµes declaradas sÃ£o de inteira responsabilidade do proprietÃ¡rio ou do possuidor do imÃ³vel rural.</p><p>O instituto da propriedade e da posse sÃ£o aqueles definidos conforme o CÃ³digo Civil. Assim sendo, entende-se como proprietÃ¡rio aquele que tem a faculdade de usar, gozar e dispor de parcela que compÃµe o imÃ³vel rural, e o direito de reavÃª-la do poder de quem quer que injustamente a possua ou detenha e possuidor a qualquer tÃ­tulo. Ã‰ considerado possuidor aquele que tem a posse plena do imÃ³vel rural, sem subordinaÃ§Ã£o (posse com animus domini), seja por direito real de fruiÃ§Ã£o sobre coisa alheia, como ocorre no caso do usufrutuÃ¡rio, seja por ocupaÃ§Ã£o, autorizada ou nÃ£o.</p>"
                }, {
                    id: "10",
                    categoria: "inscricaoCar",
                    pergunta: "O que Ã© o Recibo de InscriÃ§Ã£o e o NÃºmero de Registro no CAR?",
                    resposta: "<p>O â€œRecibo de InscriÃ§Ã£o do ImÃ³vel Rural no CARâ€ emitido pelo SICAR, que inclui o 'NÃºmero de Registro no CAR', Ã© o documento comprobatÃ³rio da efetivaÃ§Ã£o da inscriÃ§Ã£o no Sistema de Cadastro Ambiental Rural - SICAR. Formaliza entrega da documentaÃ§Ã£o exigida para a anÃ¡lise da regularidade ambiental do imÃ³vel rural e da localizaÃ§Ã£o da Ã¡rea de Reserva Legal (RL), mas nÃ£o atesta a aprovaÃ§Ã£o da localizaÃ§Ã£o da RL e nem serve como comprovaÃ§Ã£o fundiÃ¡ria.</p><p>Deve ser armazenado em pasta de fÃ¡cil acesso pois Ã© essencial ao usuÃ¡rio para cadastrar-se na Central do ProprietÃ¡rio / Possuidor e para retificar as informaÃ§Ãµes declaradas ao SICAR.</p><p>O Recibo de InscriÃ§Ã£o Ã© emitido ao usuÃ¡rio pelo SICAR em extensÃ£o '.pdf', ao ser recebido pelo SICAR o arquivo '.car'. Quando emitido ao usuÃ¡rio, esse documento '.pdf', pode ser salvo automaticamente no computador em 'Disco Local (C:) >> Users >> Nome do usuÃ¡rio >> Downloads'. Os Estados que utilizam Sistemas prÃ³prio ou MÃ³dulo de Cadastro do SICAR com receptor estadual necessitam efetuar integraÃ§Ã£o com a base de dados do SICAR para a emissÃ£o do 'Recibo de InscriÃ§Ã£o do ImÃ³vel Rural no CAR'. Nesses casos, a emissÃ£o do Recibo nÃ£o ocorrerÃ¡ imediatamente apÃ³s o envio do arquivo '.car' pelo usuÃ¡rio.</p>"
                }, {
                    id: "11",
                    categoria: "inscricaoCar",
                    pergunta: "Quais sÃ£o os Estados que utilizam a versÃ£o padrÃ£o do MÃ³dulo de Cadastro do SICAR e quais possuem Sistemas prÃ³prios ou MÃ³dulo de Cadastro do SICAR com receptor estadual?",
                    resposta: "<p>Utilizam o MÃ³dulo de Cadastro do SICAR: Alagoas, AmapÃ¡, Amazonas, CearÃ¡, Distrito Federal, GoiÃ¡s, MaranhÃ£o, ParaÃ­ba, ParanÃ¡, Pernambuco, PiauÃ­, Rio de Janeiro, Rio Grande do Norte, Roraima, Santa Catarina e Sergipe.</p><p>Utilizam sistemas prÃ³prios: Bahia, Espirito Santo, Mato Grosso do Sul, SÃ£o Paulo e Tocantins.</p><p>Utilizam o MÃ³dulo de Cadastro do SICAR com receptor estadual: Acre, Mato Grosso, Minas Gerais, ParÃ¡, Rio Grande do Sul e RondÃ´nia.</p><p>Os Estados que utilizam Sistemas prÃ³prio ou MÃ³dulo de Cadastro do SICAR com receptor estadual (Receptor SICAR estadual) necessitam efetuar integraÃ§Ã£o dos dados estaduais com a base do SICAR para a emissÃ£o do â€œRecibo de InscriÃ§Ã£o do ImÃ³vel Rural no CARâ€, documento que comprova ao proprietÃ¡rio/possuidor a efetivaÃ§Ã£o da inscriÃ§Ã£o no SICAR. Nesses casos, a emissÃ£o do Recibo nÃ£o ocorrerÃ¡ imediatamente apÃ³s o envio do arquivo â€œ.carâ€ pelo usuÃ¡rio.</p>"
                }, {
                    id: "12",
                    categoria: "inscricaoCar",
                    pergunta: "O que Ã© o Demonstrativo da SituaÃ§Ã£o do CAR?",
                    resposta: "<p>O Demonstrativo da SituaÃ§Ã£o do CAR Ã© um documento disponibilizado pelo SICAR que apresenta informaÃ§Ãµes do cadastro do imÃ³vel rural quanto:</p><ul><li>Ã  situaÃ§Ã£o do cadastro (ativo, pendente ou cancelado);</li><li>Ã  condiÃ§Ã£o do andamento do processo de anÃ¡lise do cadastro (aguardando anÃ¡lise, em anÃ¡lise, analisado com pendÃªncias etc.);</li><li>aos dados declarados no CAR relativos Ã  Cobertura do Solo, Reserva Legal, Ãreas de PreservaÃ§Ã£o Permanente e Ãreas de Uso Restrito; e </li><li>Ã  situaÃ§Ã£o da Reserva Legal.</li></ul><p>Em breve, o Demonstrativo da SituaÃ§Ã£o do CAR tambÃ©m apresentarÃ¡ informaÃ§Ãµes das Ã¡reas a recompor em Reserva Legal (RL), Ãreas de PreservaÃ§Ã£o Permanente e Ãreas de Uso Restrito, bem como Ã¡reas de excedente / passivo de RL e das envolvidas em compensaÃ§Ã£o.</p><p>PoderÃ¡ ser consultado no SICAR, pelo link <a href='http://www.car.gov.br/#/consultar'>http://www.car.gov.br/#/consultar</a>, ou pela Central do ProprietÃ¡rio / Possuidor, link <a href='http://www.car.gov.br/#/central/acesso'>http://www.car.gov.br/#/central/acesso</a>.</p>"
                }, {
                    id: "13",
                    categoria: "inscricaoCar",
                    pergunta: "Qual Ã© a diferenÃ§a entre o â€œRecibo de InscriÃ§Ã£o do ImÃ³vel Rural no CARâ€ e o â€œDemonstrativo da SituaÃ§Ã£o do CARâ€?",
                    resposta: "<p>O Recibo de InscriÃ§Ã£o emitido pelo SICAR nos termos do Â§1Âº do art. 3Âº do Decreto nÂº 8.235, de 05 de maio de 2014 constitui documento comprobatÃ³rio da efetivaÃ§Ã£o da inscriÃ§Ã£o no Sistema de Cadastro Ambiental Rural â€“ SICAR e protocolo de entrega da documentaÃ§Ã£o exigida para a anÃ¡lise da localizaÃ§Ã£o da Ã¡rea de Reserva Legal. Apresenta informaÃ§Ãµes relativas ao domÃ­nio e titularidade declaradas.</p><p>O Recibo de InscriÃ§Ã£o nÃ£o atesta a aprovaÃ§Ã£o da localizaÃ§Ã£o da Reserva Legal conforme Â§1Âº do art.14 da Lei nÂº 12.651 de 25 de maio de 2012, e nÃ£o se serve Ã  aplicaÃ§Ã£o do Â§1Âº do artigo 12 e dos artigos 16 e 18 da mesma Lei.</p><p>O Demonstrativo da SituaÃ§Ã£o do CAR disponibilizado conforme art. 20 do Decreto nÂº 8.235, de 05 de maio de 2014 refletirÃ¡ a situaÃ§Ã£o das declaraÃ§Ãµes e informaÃ§Ãµes cadastradas ou retificadas no CAR no ato de consulta, incluÃ­da a situaÃ§Ã£o do imÃ³vel, a situaÃ§Ã£o da aprovaÃ§Ã£o da localizaÃ§Ã£o da Ã¡rea de reserva legal prevista no Â§1Âº do art.14 da Lei nÂº 12.651 de 25 de maio de 2012, e os indicativos de ativos ou dÃ©ficits de remanescentes de vegetaÃ§Ã£o nativa em Ã¡reas de reserva legal e de preservaÃ§Ã£o permanente. Ã‰ disponibilizado pelo SICAR para consultas no prÃ³prio site, link http://www.car.gov.br/#/consultar, ou pela Central do ProprietÃ¡rio / Possuidor, link <a href='http://www.car.gov.br/#/central/acesso'>http://www.car.gov.br/#/central/acesso</a>.</p>"
                }, {
                    id: "14",
                    categoria: "inscricaoCar",
                    pergunta: "Qual Ã© a diferenÃ§a entre o Protocolo de preenchimento e Recibo de InscriÃ§Ã£o do ImÃ³vel Rural no CAR?",
                    resposta: "<p>O Protocolo Ã© o documento que representa que a declaraÃ§Ã£o do MÃ³dulo de Cadastro do SICAR foi preenchida e que o arquivo '.car' foi gerado, ao passo que o Recibo Ã© o documento que comprova o envio com sucesso dessas informaÃ§Ãµes Ã  base do SICAR e, por consequÃªncia, a efetivaÃ§Ã£o da inscriÃ§Ã£o do imÃ³vel rural no CAR.</p>"
                }, {
                    id: "15",
                    categoria: "inscricaoCar",
                    pergunta: "Durante a aquisiÃ§Ã£o ou venda de um imÃ³vel rural quais sÃ£o os procedimentos, em relaÃ§Ã£o ao CAR, que devem ser observados?",
                    resposta: "<p>Primeiramente, em relaÃ§Ã£o ao CAR, recomenda-se como procedimento, solicitar ao vendedor a cÃ³pia ou o nÃºmero do 'Recibo de InscriÃ§Ã£o do ImÃ³vel Rural no CAR'; e verificar, por meio do Demonstrativo da SituaÃ§Ã£o do CAR, a situaÃ§Ã£o das declaraÃ§Ãµes e informaÃ§Ãµes cadastradas ou retificadas, em especial, a situaÃ§Ã£o da aprovaÃ§Ã£o da localizaÃ§Ã£o da Ã¡rea de Reserva Legal e dos indicativos de ativos ou dÃ©ficits de remanescentes de vegetaÃ§Ã£o nativa em Ã¡reas de Reserva Legal e de PreservaÃ§Ã£o Permanente.</p>  <p>A Ã¡rea de Reserva Legal deverÃ¡ ser registrada no Ã³rgÃ£o ambiental competente por meio de inscriÃ§Ã£o no CAR, sendo vedada a alteraÃ§Ã£o de sua destinaÃ§Ã£o, nos casos de transmissÃ£o, a qualquer tÃ­tulo, ou de desmembramento, com as exceÃ§Ãµes previstas em Lei. A aprovaÃ§Ã£o da localizaÃ§Ã£o da Reserva Legal Ã© fundamental aos procedimentos de compra e venda, uma vez que, em caso de fracionamento do imÃ³vel rural, a qualquer tÃ­tulo, serÃ¡ considerada, para fins de definiÃ§Ã£o da Ã¡rea mÃ­nima de reserva, a Ã¡rea do imÃ³vel antes do fracionamento.</p><p>Por meio do Demonstrativo da SituaÃ§Ã£o do CAR tambÃ©m podem ser verificadas outras restriÃ§Ãµes do imÃ³vel rural, como sobreposiÃ§Ãµes com outros imÃ³veis rurais, com Terras IndÃ­genas, com Unidades de ConservaÃ§Ã£o da Natureza, e com Ã¡reas embargadas pelos Ã³rgÃ£os de controle e fiscalizaÃ§Ã£o ambiental</p><p>Essa verificaÃ§Ã£o Ã© feita no SICAR, link <a href='http://www.car.gov.br/#/consultar'>http://www.car.gov.br/#/consultar</a>, inserindo o nÃºmero do Recibo de InscriÃ§Ã£o do ImÃ³vel Rural no CAR ou nÃºmero do Protocolo de preenchimento. Uma vez efetivada a negociaÃ§Ã£o do imÃ³vel rural, o novo proprietÃ¡rio ou possuidor deve assegurar-se que a inscriÃ§Ã£o no CAR seja retificada para alteraÃ§Ã£o dos dados referentes Ã  transaÃ§Ã£o, incluÃ­da a atualizaÃ§Ã£o dos dados referentes aos novos proprietÃ¡rios.</p>"
                }, {
                    id: "16",
                    categoria: "inscricaoCar",
                    pergunta: "O que Ã© o arquivo de extensÃ£o â€œ.carâ€?",
                    resposta: "<p>O arquivo de extensÃ£o '.car' Ã© o arquivo gerado pelo MÃ³dulo de Cadastro do SICAR, ao gravar para envio um cadastro finalizado. O envio do arquivo de extensÃ£o '.car' depende de acesso Ã  internet, e poderÃ¡ ser feito no MÃ³dulo de Cadastro do SICAR, botÃ£o â€œENVIARâ€, ou no SICAR, aba 'ENVIAR', link <a href='http://car.gov.br/#/enviar'>http://car.gov.br/#/enviar</a>.</p><p>O sucesso no envio desse arquivo Ã© confirmado pelo 'Recibo de InscriÃ§Ã£o do ImÃ³vel Rural no CAR' emitido pelo SICAR em extensÃ£o '.pdf', Ã© o documento comprobatÃ³rio da efetivaÃ§Ã£o da inscriÃ§Ã£o no Sistema de Cadastro Ambiental Rural - SICAR.</p>"
                }, {
                    id: "17",
                    categoria: "inscricaoCar",
                    pergunta: "Onde acesso os Manuais do CAR? ",
                    resposta: "<p>No caso os sistemas desenvolvidos pelo ServiÃ§o Florestal Brasileiro, os Manuais do CAR estÃ£o disponÃ­veis no SICAR, aba â€œAtendimentoâ€, no link <a href='http://www.car.gov.br/#/suporte'>http://www.car.gov.br/#/suporte</a>. Caso existam dÃºvidas que nÃ£o forem atendidas pelos Manuais, relativas a inscriÃ§Ã£o, consulta e acompanhamento da situaÃ§Ã£o da regularizaÃ§Ã£o ambiental de seus imÃ³veis rurais, solicite ajuda ao Ã³rgÃ£o estadual competente em que se localiza o imÃ³vel. Contatos disponÃ­veis em <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "18",
                    categoria: "inscricaoCar",
                    pergunta: "Como atualizar o MÃ³dulo de Cadastro e nÃ£o perder os cadastros â€œem andamentoâ€ ou â€œconcluÃ­dosâ€, porÃ©m nÃ£o enviados ao SICAR?",
                    resposta: "<p>Para atualizar o MÃ³dulo de Cadastro e nÃ£o perder os cadastros â€œem andamentoâ€ ou â€œconcluÃ­dosâ€, porÃ©m nÃ£o enviados ao SICAR, a atualizaÃ§Ã£o deverÃ¡ ser feita pelo botÃ£o â€œAtualizarâ€ do MÃ³dulo de Cadastro instalado em seu computador. Caso a versÃ£o atualizada do aplicativo seja obtida diretamente do site e instalada novamente no computador, sobre a versÃ£o jÃ¡ instalada, os CAR preenchidos serÃ£o perdidos.</p><p>Para isso, o computador precisarÃ¡ de conexÃ£o Ã  internet. Caso o MÃ³dulo de Cadastro nÃ£o esteja atualizado, apÃ³s clicar no botÃ£o mencionado, serÃ¡ exibida uma mensagem e entÃ£o efetuado o download do pacote de atualizaÃ§Ãµes que deverÃ¡ ser instalado no computador. Ã‰ essencial solicitar a atualizaÃ§Ã£o de versÃ£o a versÃ£o atÃ© o sistema apresentar a mensagem â€œO sistema jÃ¡ estÃ¡ atualizadoâ€, dessa forma Ã© possÃ­vel saber se o MÃ³dulo de Cadastro jÃ¡ estÃ¡ com a versÃ£o atual.</p>"
                }, {
                    id: "19",
                    categoria: "inscricaoCar",
                    pergunta: "Ã‰ necessÃ¡rio apresentar documentos comprobatÃ³rios?",
                    resposta: "<p>Os documentos comprobatÃ³rios das informaÃ§Ãµes declaradas poderÃ£o ser solicitados, a qualquer tempo, pelo Ã³rgÃ£o competente, e poderÃ£o ser fornecidos por meio digital. No processo de anÃ¡lise das informaÃ§Ãµes declaradas no CAR, o Ã³rgÃ£o competente poderÃ¡ realizar vistorias no imÃ³vel rural, bem como solicitar do proprietÃ¡rio ou possuidor rural a revisÃ£o das informaÃ§Ãµes declaradas e os respectivos documentos comprobatÃ³rios. Caso detectadas pendÃªncias ou inconsistÃªncias nas informaÃ§Ãµes declaradas e nos documentos apresentados no CAR, o Ã³rgÃ£o responsÃ¡vel poderÃ¡ notificar o requerente para que preste informaÃ§Ãµes complementares ou promova a correÃ§Ã£o e adequaÃ§Ã£o das informaÃ§Ãµes prestadas.</p>"
                }, {
                    id: "20",
                    categoria: "inscricaoCar",
                    pergunta: "Quais sÃ£o os dados do imÃ³vel rural a serem declarados no CAR?",
                    resposta: "<p>Os dados do imÃ³vel rural a serem declarados na inscriÃ§Ã£o no CAR devem retratar a realidade do imÃ³vel rural no momento da declaraÃ§Ã£o. A contemplar as seguintes informaÃ§Ãµes:</p><ul><li>identificaÃ§Ã£o do proprietÃ¡rio ou possuidor do imÃ³vel rural;</li><li>comprovaÃ§Ã£o da propriedade ou posse rural;</li><li>planta georreferenciada da Ã¡rea do imÃ³vel, contendo a indicaÃ§Ã£o das coordenadas geogrÃ¡ficas com pelo menos um ponto de amarraÃ§Ã£o do perÃ­metro do imÃ³vel e o perÃ­metro das Ã¡reas de servidÃ£o administrativa, e a informaÃ§Ã£o da localizaÃ§Ã£o das Ã¡reas de remanescentes de vegetaÃ§Ã£o nativa, das Ãreas de PreservaÃ§Ã£o Permanente, das Ã¡reas de uso restrito, das Ã¡reas consolidadas e, caso existente, a localizaÃ§Ã£o da Reserva Legal.</li></ul><p>Nos casos referentes Ã  inscriÃ§Ã£o no CAR de imÃ³veis atÃ© 4 mÃ³dulos fiscais, que desenvolva atividades agrossilvipastoris, bem como de Ã¡reas tituladas de povos e comunidades tradicionais, que faÃ§am uso coletivo do seu territÃ³rio, poderÃ¡ ser apresentado um croqui, indicando a Ã¡rea do imÃ³vel rural, as Ãreas de PreservaÃ§Ã£o Permanente, as Ã¡reas de remanescentes de vegetaÃ§Ã£o nativa que formam a Reserva Legal, as Ã¡reas de servidÃµes administrativas, Ã¡reas consolidadas e as Ã¡reas de uso restrito, quando houver.</p><p>DeverÃ£o ser apresentados separadamente os dados referentes aos demais proprietÃ¡rios ou possuidores vinculados ao imÃ³vel alÃ©m daquele responsÃ¡vel pela inscriÃ§Ã£o, bem como o detalhamento das informaÃ§Ãµes comprobatÃ³rias de todas as propriedades ou posses que compÃµem o imÃ³vel rural, contemplando todos os envolvidos.</p><p>Para atendimento da elaboraÃ§Ã£o da representaÃ§Ã£o grÃ¡fica, planta ou croqui, do imÃ³vel rural, poderÃ£o ser utilizadas imagens de satÃ©lite ou outros mÃ©todos disponÃ­veis.</p><p>A localizaÃ§Ã£o e a delimitaÃ§Ã£o sobre imagens georreferenciadas de Ã¡reas de remanescentes de vegetaÃ§Ã£o nativa deverÃ£o ser indicadas sobre toda a Ã¡rea do imÃ³vel rural, inclusive, sobre:</p><ul><li>Ãreas de PreservaÃ§Ã£o Permanente;</li><li>Ã¡reas de uso restrito; e</li><li>Ã¡reas de Reserva Legal.</li></ul><p>A localizaÃ§Ã£o e a delimitaÃ§Ã£o sobre imagens georreferenciadas das Ãreas de PreservaÃ§Ã£o Permanente deverÃ£o observar:</p><ul><li>as Ã¡reas definidas no art. 4 Âº da Lei n Âº 12.651, de 2012; </li><li>as Ã¡reas criadas entorno de reservatÃ³rio d'Ã¡gua artificial, nos termos do art. 5 Âº da Lei n Âº 12.651, de 2012.</li></ul><p>A localizaÃ§Ã£o e a delimitaÃ§Ã£o sobre imagens georreferenciadas de Ã¡reas de uso restrito deverÃ£o observar os critÃ©rios descritos nos arts. 10 e 11 da Lei n Âº 12.651, de 2012, e, ainda:</p><ul><li>nas propriedades localizadas em Ã¡reas de pantanais e planÃ­cies pantaneiras deverÃ£o ser indicadas, alÃ©m do perÃ­metro da Ã¡rea destinada Ã  composiÃ§Ã£o da Reserva Legal, as Ãreas de PreservaÃ§Ã£o Permanente consolidadas atÃ© 22 de julho de 2008; e</li><li>declarar as Ã¡reas com topografia com inclinaÃ§Ã£o entre 25 Âº e 45 Âº</li></ul><p>A localizaÃ§Ã£o e a delimitaÃ§Ã£o sobre imagens georreferenciadas de Ã¡reas consolidadas deverÃ£o indicar:</p><ul><li>Ã¡reas consolidadas em Ãreas de PreservaÃ§Ã£o Permanentes e Reserva Legal atÃ© 22 de julho de 2008, conforme o disposto no art. 61-A da Lei n Âº 12.651, de 2012; e</li><li>as Ã¡reas de uso restrito, conforme o disposto nos arts. 10 e 11 da Lei n Âº 12.651, de 2012.</li></ul><p>A localizaÃ§Ã£o e a delimitaÃ§Ã£o sobre imagens georreferenciadas de Ã¡reas de Reserva Legal deverÃ£o observar os seguintes critÃ©rios:</p><ul><li>o cÃ¡lculo da Ã¡rea de Reserva Legal dos imÃ³veis que apresentem as Ã¡reas de servidÃ£o administrativa, serÃ¡ o resultado da exclusÃ£o dessas do somatÃ³rio da Ã¡rea total do imÃ³vel rural;</li><li>para a Ã¡rea de Reserva Legal que jÃ¡ tenha sido averbada na matrÃ­cula do imÃ³vel, ou no Termo de Compromisso, quando se tratar de posse, poderÃ¡ o proprietÃ¡rio ou possuidor informar, em ambos os casos, no ato da inscriÃ§Ã£o, as coordenadas do perÃ­metro da Reserva Legal ou comprovar por meio da apresentaÃ§Ã£o da certidÃ£o de registro de imÃ³veis onde conste a averbaÃ§Ã£o; e</li><li>para os casos em que houve supressÃ£o da vegetaÃ§Ã£o, antes de 22 de julho de 2008, e que foram mantidos os percentuais de Reservas Legais previstos na legislaÃ§Ã£o em vigor Ã  Ã©poca, os proprietÃ¡rios ou possuidores de imÃ³veis rurais deverÃ£o comprovar que a supressÃ£o da vegetaÃ§Ã£o ocorreu conforme disposto no art. 68 da Lei n Âº 12.651, de 2012.</li></ul><p>A localizaÃ§Ã£o e a delimitaÃ§Ã£o sobre imagens georreferenciadas de Ã¡reas de Reserva Legal nos imÃ³veis rurais que detinham, em 22 de julho de 2008, Ã¡rea de atÃ© 4 (quatro) mÃ³dulos fiscais e que possuam remanescente de vegetaÃ§Ã£o nativa em percentuais inferiores ao previsto no art. 12 da Lei n Âº 12.651, de 2012, serÃ¡ descrita sobre a Ã¡rea ocupada com a vegetaÃ§Ã£o nativa existente em 22 de julho de 2008, vedadas novas conversÃµes para uso alternativo do solo, conforme disposto no art. 67 da Lei n Âº 12.651, de 2012.</p><p>Para cumprimento da manutenÃ§Ã£o da Ã¡rea de Reserva Legal, nas pequenas propriedades ou posses rurais familiares, poderÃ£o ser computadas as Ã¡reas com plantios de Ã¡rvores frutÃ­feras, ornamentais ou industriais, compostas por espÃ©cies exÃ³ticas, cultivadas em sistema intercalar ou em consÃ³rcio com espÃ©cies nativas da regiÃ£o em sistemas agroflorestais, conforme disposto no art. 54 da Lei n Âº 12.651, de 2012.</p><p>Nos casos em que as Reservas Legais nÃ£o atendam aos percentuais mÃ­nimos estabelecidos no art. 12 da Lei 12.651/2012, o proprietÃ¡rio ou possuidor rural poderÃ¡ solicitar a utilizaÃ§Ã£o, caso os requisitos estejam preenchidos, isolada ou conjuntamente, dos mecanismos previstos nos arts. 15, 16 e 66 da Lei n Âº 12.651, de 2012, para fins de alcance do percentual, quais sejam:</p><ul><li>o cÃ´mputo das Ãreas de PreservaÃ§Ã£o Permanente no cÃ¡lculo do percentual da Reserva Legal;</li><li>a instituiÃ§Ã£o de regime de Reserva Legal em condomÃ­nio ou coletiva entre propriedades rurais;</li><li>a recomposiÃ§Ã£o;</li><li>a regeneraÃ§Ã£o natural da vegetaÃ§Ã£o; ou</li><li>a compensaÃ§Ã£o da Reserva Legal</li></ul><p>O proprietÃ¡rio ou possuidor de imÃ³vel rural que nÃ£o dispÃµe dos percentuais estabelecidos nos incisos I e II do art. 12 da Lei n Âº 12.651, de 2012 e que deseje utilizar a compensaÃ§Ã£o de Reserva Legal em Unidade de ConservaÃ§Ã£o, conforme previsto no inciso III do Â§ 5 Âº do art. 66 da mesma Lei, poderÃ¡ indicar no ato da sua inscriÃ§Ã£o a pretensÃ£o de adoÃ§Ã£o dessa alternativa para regularizaÃ§Ã£o, conforme disposto no art. 26, desta InstruÃ§Ã£o Normativa.</p><p>Os proprietÃ¡rios ou possuidores de imÃ³veis rurais que jÃ¡ compensaram a Reserva Legal em outro imÃ³vel, em qualquer das modalidades, deverÃ£o indicar no ato da inscriÃ§Ã£o o nÃºmero de inscriÃ§Ã£o no CAR do imÃ³vel de origem da Reserva Legal ou a identificaÃ§Ã£o do proprietÃ¡rio ou possuidor do imÃ³vel rural.</p><p>Para o imÃ³vel rural que contemple mais de um proprietÃ¡rio ou possuidor, pessoa fÃ­sica ou jurÃ­dica, deverÃ¡ ser feita apenas uma Ãºnica inscriÃ§Ã£o no CAR, com indicaÃ§Ã£o da identificaÃ§Ã£o correspondente a todos os proprietÃ¡rios ou possuidores.</p><p>Os proprietÃ¡rios ou possuidores de imÃ³veis rurais, que dispÃµem de mais de uma propriedade ou posse em Ã¡rea contÃ­nua, deverÃ£o efetuar uma Ãºnica inscriÃ§Ã£o para esses imÃ³veis.</p><p>Para o cumprimento dos percentuais da Reserva Legal, bem como para a definiÃ§Ã£o da faixa de recomposiÃ§Ã£o de Ãreas de PreservaÃ§Ã£o Permanente, previstos nos arts. 12 e 61-A da Lei n Âº 12.651, de 2012, o proprietÃ¡rio ou possuidor deverÃ¡ inscrever a totalidade das Ã¡reas.</p><p>Quando o imÃ³vel rural tiver seu perÃ­metro localizado em mais de um ente federado, a inscriÃ§Ã£o no CAR dar-se-Ã¡ naquele que contemple o maior percentual de sua Ã¡rea, em hectare.</p><p>Diante do desmembramento ou fracionamento de imÃ³vel rural jÃ¡ cadastrado no CAR, o proprietÃ¡rio ou possuidor responsÃ¡vel deverÃ¡ promover a atualizaÃ§Ã£o do cadastro realizado. Para o imÃ³vel rural originado do desmembramento ou fracionamento, o proprietÃ¡rio ou possuidor de imÃ³vel rural deverÃ¡ realizar nova inscriÃ§Ã£o.</p><p>O proprietÃ¡rio de imÃ³vel rural que pretende destinar as Ã¡reas excedentes de Reserva Legal, parcial ou integralmente, para a compensaÃ§Ã£o de Reserva Legal, conforme previsto no art. 66 da Lei n Âº 12.651, de 2012, poderÃ¡ declarar essa intenÃ§Ã£o no ato da sua inscriÃ§Ã£o.</p><p>SerÃ¡ facultado ao proprietÃ¡rio ou possuidor de imÃ³vel rural declarar no CAR os autos de infraÃ§Ã£o emitidos pelos Ã³rgÃ£os competentes, anteriores a 22 de julho de 2008, referentes ao imÃ³vel rural cadastrado, conforme estabelecido no art. 60 da Lei n Âº 12.651, de 2012.</p><p>As informaÃ§Ãµes declaradas no CAR deverÃ£o ser atualizadas pelo proprietÃ¡rio ou possuidor rural sempre que houver notificaÃ§Ã£o dos Ã³rgÃ£os competentes ou quando houver alteraÃ§Ã£o de natureza dominial ou possessÃ³ria, mediante autorizaÃ§Ã£o do Ã³rgÃ£o competente.</p>"
                }, {
                    id: "21",
                    categoria: "inscricaoCar",
                    pergunta: "Ã‰ obrigatÃ³rio declarar na inscriÃ§Ã£o os dados de outros proprietÃ¡rios ou possuidores vinculados ao mesmo imÃ³vel?",
                    resposta: "<p>Sim, os dados referentes aos demais proprietÃ¡rios ou possuidores vinculados ao imÃ³vel alÃ©m daquele responsÃ¡vel pela inscriÃ§Ã£o, bem como o detalhamento das informaÃ§Ãµes comprobatÃ³rias de identificaÃ§Ã£o dos proprietÃ¡rios/ possuidores, e de todas as propriedades ou posses que compÃµem o imÃ³vel rural, deverÃ£o ser apresentados separadamente, contemplando todos os envolvidos.</p>"
                }, {
                    id: "22",
                    categoria: "inscricaoCar",
                    pergunta: "O que Ã© considerado imÃ³vel rural para o CAR?",
                    resposta: "<p>Para efeitos de inscriÃ§Ã£o no CAR, o imÃ³vel rural Ã© definido como de Ã¡rea contÃ­nua, localizado em zona rural ou urbana, que se destine ou possa se destinar Ã  exploraÃ§Ã£o agrÃ­cola, pecuÃ¡ria, extrativa vegetal, florestal ou agroindustrial, conforme disposto no inciso I do art. 4Âº da Lei no 8.629, de 25 de fevereiro de 1993, podendo ser caracterizado como:</p><ul><li>pequena propriedade ou posse: com Ã¡rea de atÃ© 4 (quatro)  mÃ³dulos  fiscais, incluindo as terras indÃ­genas demarcadas e demais Ã¡reas tituladas de povos e comunidades tradicionais que faÃ§am uso coletivo do seu territÃ³rio;</li><li>mÃ©dia propriedade ou posse: com Ã¡rea superior a 4 (quatro) atÃ© 15 (quinze) mÃ³dulos fiscais;</li><li>grande propriedade ou posse: com Ã¡rea superior a 15 (quinze) mÃ³dulos fiscais</li></ul><p>O conjunto de propriedades ou posses, em Ã¡rea contÃ­nua, pertencentes Ã s mesmas pessoas, fÃ­sicas ou jurÃ­dicas, serÃ¡ considerado como um Ãºnico imÃ³vel rural devendo ser feita uma Ãºnica inscriÃ§Ã£o declarando as informaÃ§Ãµes contidas nos respectivos documentos comprobatÃ³rios. Ressaltando que nÃ£o Ã© considerada quebra de continuidade a existÃªncia de estradas, cÃ³rregos e pontes, por exemplo. Para o cumprimento dos percentuais da Reserva Legal, bem como para a definiÃ§Ã£o da faixa de recomposiÃ§Ã£o de Ãreas de PreservaÃ§Ã£o Permanente, previstos na Lei 12.651/12, serÃ¡ considerada a totalidade das Ã¡reas de propriedades e posses.</p>"
                }, {
                    id: "23",
                    categoria: "inscricaoCar",
                    pergunta: "O que Ã© Ã¡rea de servidÃ£o administrativa?",
                    resposta: "<p>Ãrea de servidÃ£o administrativa Ã© uma Ã¡rea de utilidade pÃºblica declarada pelo Poder PÃºblico que afetem os imÃ³veis rurais. (inciso V do artigo 2Âº da IN MMA nÂº 2, de 6/5/2014).</p><p>A servidÃ£o administrativa Ã© o Ã´nus ou encargo imposto por uma disposiÃ§Ã£o legal sobre uma propriedade e limitadora do exercÃ­cio do direito da propriedade, por razÃµes de utilidade pÃºblica. Resulta imediatamente da Lei e do fato de existir um objeto que a Lei considere como dominante sobre os prÃ©dios vizinhos.</p> <p>As servidÃµes administrativas sÃ£o as Ã¡reas ocupadas por rodovias, linhas de transmissÃ£o e reservatÃ³rios para abastecimento ou geraÃ§Ã£o de energia declaradas como utilidade pÃºblica ou interesse social, entre outras. Essas Ã¡reas, quando existentes, ao serem declaradas no CAR, sÃ£o descontadas da Ã¡rea total do imÃ³vel para fins de cÃ¡lculo do percentual para Reserva Legal, conforme previsto na Lei 12.651/12.</p>"
                }, {
                    id: "24",
                    categoria: "inscricaoCar",
                    pergunta: "O que Ã© Ã¡rea consolidada?",
                    resposta: "<p>Ãrea rural consolidada Ã© a Ã¡rea do imÃ³vel rural com ocupaÃ§Ã£o antrÃ³pica preexistente a 22 de julho de 2008, com edificaÃ§Ãµes, benfeitorias ou atividades agrossilvipastoris, admitida, neste Ãºltimo caso, a adoÃ§Ã£o do regime de pousio.</p>"
                }, {
                    id: "25",
                    categoria: "inscricaoCar",
                    pergunta: "O imÃ³vel rural que possui Reserva Legal averbada ou termo de compromisso para averbaÃ§Ã£o Ã© obrigado a ser inscrito no CAR?  Qual Ã© o tratamento para esses imÃ³veis?",
                    resposta: "<p>Sim, a inscriÃ§Ã£o no CAR Ã© obrigatÃ³ria para todas as propriedades e posses rurais no Brasil. Nos casos em que a Reserva Legal jÃ¡ tenha sido averbada na matrÃ­cula do imÃ³vel e a averbaÃ§Ã£o identifique o perÃ­metro e a localizaÃ§Ã£o da Reserva, o proprietÃ¡rio nÃ£o serÃ¡ obrigado a delimitar a localizaÃ§Ã£o da Reserva Legal na inscriÃ§Ã£o. No entanto, deverÃ¡ ser apresentada, para fins de comprovaÃ§Ã£o, a certidÃ£o de registro de imÃ³vel onde conste a averbaÃ§Ã£o da Reserva Legal ou termo de compromisso jÃ¡ firmado nos casos de posse.</p>"
                }, {
                    id: "26",
                    categoria: "inscricaoCar",
                    pergunta: "Quais sÃ£o os requisitos mÃ­nimos que um computador deve possuir para instalaÃ§Ã£o do MÃ³dulo de Cadastro do SICAR?",
                    resposta: "<p>Requisitos mÃ­nimos:</p><ul><li>Processador multinÃºcleo de 1,3 GHz ou mais rÃ¡pido;</li><li>Windows ServerÂ® 2003 R2 (32 bits e 64 bits);</li><li>Windows ServerÂ® 2008 ou 2008 R2 (32 bits e 64 bits); </li><li>Windows 7 (32 bits e 64 bits); </li><li>Windows 8 (32 bits e 64 bits).</li></ul><p>Os requisitos mÃ­nimos podem ser consultados no site do CAR, por meio do link <a href='http://www.car.gov.br/#/baixar'>http://www.car.gov.br/#/baixar</a>, ao selecionar a sigla do Estado em que se localiza o imÃ³vel a ser declarado.</p>"
                }, {
                    id: "27",
                    categoria: "inscricaoCar",
                    pergunta: "HÃ¡ custos para a inscriÃ§Ã£o do imÃ³vel rural no CAR?",
                    resposta: "<p>NÃ£o, segundo o artigo 13 da InstruÃ§Ã£o Normativa MMA nÂº 2, de 6/5/2014, a inscriÃ§Ã£o e o registro do imÃ³vel rural no CAR Ã© gratuita.</p><p>O registro do imÃ³vel rural no Cadastro Ambiental Rural (CAR) Ã© um ato administrativo sem previsÃ£o de taxaÃ§Ã£o, porÃ©m, considerando que a adequada inscriÃ§Ã£o de um imÃ³vel rural no CAR, e posterior envio Ã  base de dados do SICAR, depende da interpretaÃ§Ã£o de dispositivos legais, de acesso Ã  internet, e de habilidades para operar computadores e ferramentas do SICAR, dependendo da complexidade da situaÃ§Ã£o do imÃ³vel pode haver necessidade de contrataÃ§Ã£o de um profissional para a execuÃ§Ã£o do serviÃ§o, com consequente cobranÃ§a. A ConstituiÃ§Ã£o Federal nÃ£o veda a cobranÃ§a, por entidades privadas, pela prestaÃ§Ã£o de serviÃ§os de apoio tÃ©cnico a particulares para o cumprimento de exigÃªncias legais controladas pelo Estado, tais como a inscriÃ§Ã£o de imÃ³veis rurais no CAR com uso dos sistemas de informaÃ§Ãµes oficiais disponÃ­veis.</p><p>Como ato declaratÃ³rio de particulares por forÃ§a de lei, o cadastramento de imÃ³veis rurais no CAR nÃ£o Ã© de iniciativa do poder pÃºblico, cabendo a este apenas disponibilizar, na rede mundial de computadores, os sistemas eletrÃ´nicos de informaÃ§Ãµes para que os proprietÃ¡rios e possuidores rurais possam cumprir com sua obrigaÃ§Ã£o ambiental. O MinistÃ©rio do Meio Ambiente (MMA) disponibiliza ao pÃºblico, gratuitamente, o MÃ³dulo de Cadastro do Sistema de Cadastro Ambiental Rural (SICAR) no sÃ­tio eletrÃ´nico <a href='http://www.car.gov.br/#/'>http://www.car.gov.br/#/</a>, alÃ©m de orientaÃ§Ãµes necessÃ¡rias para que os titulares de imÃ³veis rurais, ou seus prepostos declarantes, possam elaborar os croquis eletrÃ´nicos e executar o devido registro pÃºblico gratuito.</p><p>Cabe ao poder pÃºblico prestar apoio tÃ©cnico e jurÃ­dico, assegurada a gratuidade, na inscriÃ§Ã£o de imÃ³veis rurais de atÃ© 4 (quatro) mÃ³dulos fiscais que desenvolvam atividades agrossilvipastoris, bem como para imÃ³veis de Ã¡reas tituladas de povos e comunidades tradicionais que faÃ§am uso coletivo do seu territÃ³rio. Para os demais casos, a inscriÃ§Ã£o poderÃ¡ ser efetuada pelo prÃ³prio proprietÃ¡rio/possuidor, caso este se sinta apto, ou por terceiro, na funÃ§Ã£o de cadastrante.</p><p>Para mais informaÃ§Ãµes busque orientaÃ§Ãµes junto ao Ã³rgÃ£o estadual competente, que pode ser encontrado no link <a href='http://www.car.gov.br/#/suporte'>http://www.car.gov.br/#/suporte</a>.</p>"
                }, {
                    id: "28",
                    categoria: "inscricaoCar",
                    pergunta: "A inscriÃ§Ã£o serve como comprovaÃ§Ã£o fundiÃ¡ria?",
                    resposta: "Conforme estipulado na Lei 12.651/2012, o CAR nÃ£o serÃ¡ considerado tÃ­tulo para fins de reconhecimento do direito de propriedade ou posse, tampouco substitui o cadastramento junto ao Sistema Nacional de Cadastro Rural â€“ SNCR do Instituto Nacional de ColonizaÃ§Ã£o e Reforma AgrÃ¡ria â€“ INCRA, conforme exigido no Art. 2Â° da Lei nÂº 10.267, de 28 de agosto de 2001, e a necessidade de certificaÃ§Ã£o da poligonal do perÃ­metro do imÃ³vel junto ao INCRA, previsto no Â§ 5Âº do art. 176 da Lei nÂº 6.015, de 31 de dezembro de 1973."
                }, {
                    id: "29",
                    categoria: "inscricaoCar",
                    pergunta: "Quais sÃ£o as consequÃªncias e sanÃ§Ãµes para o imÃ³vel rural que nÃ£o estiver inscrito no CAR? ",
                    resposta: "<p>NÃ£o estÃ¡ regulamentada em norma federal explicitamente a previsÃ£o de sanÃ§Ãµes para a nÃ£o adesÃ£o ao CAR. No entanto, existem sanÃ§Ãµes para o descumprimento da manutenÃ§Ã£o da Ã¡rea com cobertura de vegetaÃ§Ã£o nativa a tÃ­tulo de Reserva Legal.</p><p>EstÃ¡ prevista na Lei 12.651/12, como consequÃªncias para a nÃ£o inscriÃ§Ã£o do imÃ³vel no CAR, a impossibilidade de acesso ao crÃ©dito rural a partir de 31 de dezembro de 2017, impedimento no acesso a autorizaÃ§Ãµes de supressÃ£o de vegetaÃ§Ã£o e outras licenÃ§as, bem como restriÃ§Ãµes ao ingresso em programas de apoio e pagamentos por serviÃ§os ambientais governamentais. AlÃ©m disso, a inscriÃ§Ã£o no CAR Ã© condiÃ§Ã£o obrigatÃ³ria para a adesÃ£o ao PRA. Essas sÃ£o as consequÃªncias conforme legislaÃ§Ã£o Federal existente, podendo existir outras restriÃ§Ãµes, ou atÃ© sanÃ§Ãµes, em Ã¢mbito Estadual, Distrital ou Municipal. InformaÃ§Ãµes detalhadas podem ser obtidas junto ao Ã³rgÃ£o estadual competente. Contatos disponÃ­veis em <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "30",
                    categoria: "inscricaoCar",
                    pergunta: "O que acontece se existirem divergÃªncias de tamanho de Ã¡rea entre a existente em documentos e a delimitada no MÃ³dulo de Cadastro?",
                    resposta: "<p>Se a Ã¡rea informada na aba â€œDocumentaÃ§Ã£oâ€ do MÃ³dulo de Cadastro do SICAR for diferente daquela vetorizada na aba â€œGeoâ€, o sistema sinalizarÃ¡ a existÃªncia de divergÃªncia. Caso os valores ultrapassem os percentuais de tolerÃ¢ncia do SICAR, o sistema nÃ£o permitirÃ¡ a finalizaÃ§Ã£o do preenchimento da declaraÃ§Ã£o e a geraÃ§Ã£o do arquivo â€œ.carâ€. Caso os valores estejam abaixo dos percentuais de tolerÃ¢ncia, o sistema permitirÃ¡ a finalizaÃ§Ã£o do preenchimento, porÃ©m, durante a anÃ¡lise, os tÃ©cnicos dos Ã³rgÃ£os estaduais competentes poderÃ£o notificar o proprietÃ¡rio/possuidor a retificar as informaÃ§Ãµes pertinentes ou apresentar documentaÃ§Ã£o comprobatÃ³ria.</p><p>A regra e a tolerÃ¢ncia utilizada pelo MÃ³dulo de Cadastro do SICAR para ImÃ³veis rurais atÃ© 4 mÃ³dulos fiscais sÃ£o:</p><ul><li>NÃ£o Ã© gerado o arquivo â€œ.carâ€ se a vetorizaÃ§Ã£o for divergente 100% da Ã¡rea declarada em documento. Para isso o sistema faz duas checagens:<ul><li>NÃ£o gera â€œ.carâ€ se a vetorizaÃ§Ã£o Ã© maior ou igual ao dobro da Ã¡rea declarada. Ex: Ãrea total em Documento = 50ha e VetorizaÃ§Ã£o = 100ha </li><li>NÃ£o gera â€œ.carâ€ se a declaraÃ§Ã£o em documento maior ou igual ao dobro da Ã¡rea vetorizada. Ex: Ãrea total em Documento = 100ha e VetorizaÃ§Ã£o = 50ha</li></ul></li></ul><p>A regra e a tolerÃ¢ncia utilizadas pelo MÃ³dulo de Cadastro do SICAR para ImÃ³veis rurais acima de 4 mÃ³dulos fiscais sÃ£o:</p><ul><li>NÃ£o Ã© gerado â€œ.carâ€ se a vetorizaÃ§Ã£o for divergente 50% da Ã¡rea declarada em documento. Para isso o sistema faz duas checagens:<ul><li>NÃ£o gera o arquivo â€œ.carâ€ se a vetorizaÃ§Ã£o for maior ou igual 1,5 vezes que a Ã¡rea declarada. Ex: Ãrea total em Documento = 100ha e VetorizaÃ§Ã£o = 150ha</li><li>NÃ£o gera â€œ.carâ€ se a declaraÃ§Ã£o for maior ou igual 1,5 vezes maior que a Ã¡rea vetorizada. Ex: Ãrea total em Documento = 150ha e VetorizaÃ§Ã£o = 100ha </li></ul></li></ul><p>Para os casos em que a Ã¡rea da propriedade/posse vetorizada seja maior que Ã¡rea constante em documentaÃ§Ã£o, superando os limites de tolerÃ¢ncia e impossibilitando a finalizaÃ§Ã£o do preenchimento do cadastro, o usuÃ¡rio deve declarar a Ã¡rea vetorizada excedente na etapa documentaÃ§Ã£o como posse por meio do Termo de AutodeclaraÃ§Ã£o.</p>"
                }, {
                    id: "31",
                    categoria: "inscricaoCar",
                    pergunta: "Por que na aba â€œGeoâ€ do MÃ³dulo de Cadastro as imagens somem ao aumentar o zoom?",
                    resposta: "<p>As imagens somem ao aumentar o zoom quando a transferÃªncia nÃ£o ocorre por completo, embora, algumas vezes, seja exibida mensagem informando que o municÃ­pio foi baixado com sucesso. Caso esta situaÃ§Ã£o ocorra Ã© necessÃ¡rio proceder novamente o download das imagens em â€œBaixar Imagensâ€, no MÃ³dulo de Cadastro, atÃ© que deixem de desaparecer ao aumentar o zoom no local de interesse. Para baixar por completo as imagens, no MÃ³dulo de Cadastro, Ã© importante um acesso de qualidade Ã  internet.</p>"
                }, {
                    id: "32",
                    categoria: "retificacaoCar",
                    pergunta: "Como consultar se o imÃ³vel rural possui inscriÃ§Ã£o no CAR?",
                    resposta: "<p>Para consultar se o imÃ³vel rural possui inscriÃ§Ã£o no CAR basta acessar o link <a href='http://www.car.gov.br/#/consultar'>http://www.car.gov.br/#/consultar</a>, onde serÃ¡ exigido o nÃºmero do Protocolo ou o nÃºmero do Recibo de InscriÃ§Ã£o do ImÃ³vel Rural no CAR.</p>"
                }, {
                    id: "33",
                    categoria: "retificacaoCar",
                    pergunta: "Como acompanhar a situaÃ§Ã£o e/ou condiÃ§Ã£o do cadastro no SICAR?",
                    resposta: "<p>O usuÃ¡rio pode acompanhar a situaÃ§Ã£o e/ou condiÃ§Ã£o do cadastro no SICAR em todas as suas etapas â€“ inscriÃ§Ã£o, anÃ¡lise e regularizaÃ§Ã£o ambiental - por meio do Demonstrativo da SituaÃ§Ã£o do CAR, que pode ser consultado pelo link http://www.car.gov.br/#/consultar ou pela Central do ProprietÃ¡rio / Possuidor, link <a href='http://www.car.gov.br/#/central/acesso'>http://www.car.gov.br/#/central/acesso</a>.</p>"
                }, {
                    id: "34",
                    categoria: "retificacaoCar",
                    pergunta: "Quais sÃ£o as possÃ­veis â€œSituaÃ§Ãµesâ€ de um imÃ³vel declarado no CAR?",
                    resposta: "<p>As â€œSituaÃ§Ãµesâ€ possÃ­veis de um imÃ³vel rural declarado no CAR sÃ£o: </p><ul><li>ativo<ul><li>apÃ³s concluÃ­da a inscriÃ§Ã£o no CAR;</li><li>enquanto estiverem sendo cumpridas as obrigaÃ§Ãµes de atualizaÃ§Ã£o das informaÃ§Ãµes, conforme Â§ 3Âº do art. 6Âº do Decreto nÂº 7.830, de 2012, decorrente da anÃ¡lise; e</li><li>quando analisadas as informaÃ§Ãµes declaradas no CAR e constatada a regularidade das informaÃ§Ãµes relacionadas Ã s APPâ€™s, Ã¡reas de uso restrito e Reserva Legal.</li></ul></li><li>pendente<ul><li>quando houver notificaÃ§Ã£o de irregularidades relativas Ã s Ã¡reas de reserva legal, de preservaÃ§Ã£o permanente, de uso restrito, de uso alternativo do solo e de remanescentes de vegetaÃ§Ã£o nativa, dentre outras;</li><li>enquanto nÃ£o forem cumpridas as obrigaÃ§Ãµes de atualizaÃ§Ã£o das informaÃ§Ãµes decorrentes de notificaÃ§Ãµes;</li><li>quando constatadas sobreposiÃ§Ãµes do imÃ³vel rural com Terras IndÃ­genas, Unidades de ConservaÃ§Ã£o, Terras da UniÃ£o e Ã¡reas consideradas impeditivas pelos Ã³rgÃ£os competentes;</li><li>quando constatadas sobreposiÃ§Ã£o do imÃ³vel rural com Ã¡reas embargadas pelos Ã³rgÃ£os competentes;</li><li>quando constatada sobreposiÃ§Ã£o de perÃ­metro de um imÃ³vel com o perÃ­metro de outro imÃ³vel rural;</li><li>quando constatada declaraÃ§Ã£o incorreta, conforme o previsto no art. 7Âº do Decreto nÂº 7.830, de 2012; e</li><li>enquanto nÃ£o forem cumpridas quaisquer diligÃªncias notificadas aos inscritos nos prazos determinados;</li></ul></li><li>cancelado<ul><li>quando constatado que as informaÃ§Ãµes declaradas sÃ£o total ou parcialmente falsas, enganosas ou omissas, nos termos do Â§ 1Âº do art. 6Âº do Decreto nÂº 7.830, de 2012;</li><li>apÃ³s o nÃ£o cumprimento dos prazos estabelecidos nas notificaÃ§Ãµes; ou</li><li>por decisÃ£o judicial ou decisÃ£o administrativa do Ã³rgÃ£o competente devidamente justificada; e</li><li>por solicitaÃ§Ã£o devidamente justificada por parte do proprietÃ¡rio/possuidor ou  representante legal, mediante anÃ¡lise e aprovaÃ§Ã£o do Ã³rgÃ£o estadual competente</li></ul></li></ul><p>A situaÃ§Ã£o de um CAR pode ser consultada em <a href='http://www.car.gov.br/#/consultar'>http://www.car.gov.br/#/consultar</a>  e por meio da Central do ProprietÃ¡rio/Possuidor, pelo Demonstrativo da SituaÃ§Ã£o do CAR.</p>"
                }, {
                    id: "35",
                    categoria: "retificacaoCar",
                    pergunta: "O que pode levar ao cancelamento da inscriÃ§Ã£o de um imÃ³vel rural no CAR?",
                    resposta: "<p>O CAR de um imÃ³vel rural poderÃ¡ ser cancelado pelo Ã³rgÃ£o estadual competente:</p><ul><li>quando constatado que as informaÃ§Ãµes declaradas sÃ£o total ou parcialmente falsas, enganosas ou omissas, nos termos do Â§ 1Âº do art. 6Âº do Decreto nÂº 7.830, de 2012;</li><li>apÃ³s o nÃ£o cumprimento dos prazos estabelecidos nas notificaÃ§Ãµes; ou</li><li>por decisÃ£o judicial ou decisÃ£o administrativa do Ã³rgÃ£o competente devidamente justificada; e</li><li>por solicitaÃ§Ã£o devidamente justificada por parte do proprietÃ¡rio/possuidor ou  representante legal, mediante anÃ¡lise e aprovaÃ§Ã£o do Ã³rgÃ£o estadual competente.</li></ul>"
                }, {
                    id: "36",
                    categoria: "retificacaoCar",
                    pergunta: "Como saber se o cadastro do imÃ³vel rural no CAR foi analisado?",
                    resposta: "<p>A condiÃ§Ã£o do CAR indica a fase do processo de anÃ¡lise do cadastro. Para saber se o CAR foi analisado, proprietÃ¡rios e possuidores poderÃ£o utilizar a Central do ProprietÃ¡rio/Possuidor do SICAR, ou ferramenta de consulta do Demonstrativo da SituaÃ§Ã£o do CAR disponÃ­vel no sÃ­tio eletrÃ´nico do SICAR, link <a href='http://www.car.gov.br/#/consultar'>http://www.car.gov.br/#/consultar</a>. As consultas pelo SICAR tambÃ©m poderÃ£o ser feitas por outros interessados, desde de que munidos do nÃºmero de registro do Recibo do CAR ou de posso do protocolo de preenchimento do CAR.</p><p>Na Central do ProprietÃ¡rio/Possuidor, disponÃ­vel no link <a href='http://www.car.gov.br/#/central/acesso'>http://www.car.gov.br/#/central/acesso</a>, existe a aba â€œMensagensâ€ que armazena todas as comunicaÃ§Ãµes emitidas pelo Ã³rgÃ£o estadual competente, onde serÃ£o recebidos comunicados ao inÃ­cio e ao tÃ©rmino da anÃ¡lise do respectivo CAR. Ao acessar a â€œPagina Inicialâ€ da Central do ProprietÃ¡rio/Possuidor tambÃ©m Ã© informada, pelo Demonstrativo do CAR, a condiÃ§Ã£o em que se encontra o seu cadastro em relaÃ§Ã£o Ã  anÃ¡lise.</p>"
                }, {
                    id: "37",
                    categoria: "retificacaoCar",
                    pergunta: "Quem Ã© o responsÃ¡vel pela anÃ¡lise do cadastro dos imÃ³veis rurais no CAR?",
                    resposta: "O responsÃ¡vel pela anÃ¡lise do cadastro dos imÃ³veis rurais no CAR Ã© o Ã³rgÃ£o estadual competente ou instituiÃ§Ã£o por ele habilitada que deverÃ¡ aprovar a localizaÃ§Ã£o da Reserva Legal, conforme disposto na Lei 12.651/12."
                }, {
                    id: "38",
                    categoria: "retificacaoCar",
                    pergunta: "Como Ã© feita a anÃ¡lise do cadastro dos imÃ³veis rurais no CAR?",
                    resposta: "<p>A anÃ¡lise do cadastro dos imÃ³veis rurais no CAR Ã© feita com base nas informaÃ§Ãµes declaradas no CAR referentes Ã : identificaÃ§Ã£o do proprietÃ¡rio ou possuidor rural; comprovaÃ§Ã£o da propriedade ou posse; e do perÃ­metro do imÃ³vel, dos remanescentes de vegetaÃ§Ã£o nativa, das Ãreas de PreservaÃ§Ã£o Permanente, das Ãreas de Uso Restrito, das Ã¡reas consolidadas e, caso existente, da localizaÃ§Ã£o da Reserva Legal.</p><p>A anÃ¡lise dos dados declarados no CAR Ã© de responsabilidade do Ã³rgÃ£o estadual, distrital ou municipal competente. Uma vez iniciada a anÃ¡lise dos dados, o proprietÃ¡rio ou possuidor do imÃ³vel rural nÃ£o poderÃ¡ alterar ou retificar as informaÃ§Ãµes cadastradas atÃ© o encerramento dessa etapa, exceto nos casos de notificaÃ§Ãµes emitidas pelo respectivo Ã³rgÃ£o competente.</p><p>Se constatada a sobreposiÃ§Ã£o, ficarÃ£o pendentes os cadastros dos imÃ³veis sobrepostos no CAR, atÃ© que os responsÃ¡veis procedam Ã  retificaÃ§Ã£o, Ã  complementaÃ§Ã£o ou Ã  comprovaÃ§Ã£o das informaÃ§Ãµes declaradas, conforme demandado pelo Ã³rgÃ£o competente.</p><p>A anÃ¡lise do Ã³rgÃ£o competente observarÃ¡ a localizaÃ§Ã£o da Reserva Legal, bem como a manutenÃ§Ã£o da proporcionalidade da Reserva Legal instituÃ­da dos imÃ³veis rurais decorrentes do desmembramento ou fracionamento.</p><p>Em caso de fracionamento do imÃ³vel rural, a qualquer tÃ­tulo, inclusive para assentamentos pelo Programa de Reforma AgrÃ¡ria, serÃ¡ considerada a tÃ­tulo de Reserva Legal a Ã¡rea com cobertura de vegetaÃ§Ã£o nativa antes do fracionamento;</p><p>O SICAR dispÃµe de mecanismo de anÃ¡lise automÃ¡tica das informaÃ§Ãµes declaradas e dispositivo para recepÃ§Ã£o de documentos digitalizados, que contemplarÃ¡, no mÃ­nimo, a verificaÃ§Ã£o dos seguintes aspectos:</p><ol><li>vÃ©rtices do perÃ­metro do imÃ³vel rural inseridos no limite do MunicÃ­pio informado no CAR;</li><li>diferenÃ§a entre a Ã¡rea do imÃ³vel rural declarada que consta no documento de propriedade e a Ã¡rea obtida pela delimitaÃ§Ã£o do perÃ­metro do imÃ³vel rural no aplicativo de georreferenciamento do sistema CAR;</li><li>Ã¡rea de Reserva Legal em percentual equivalente, inferior ou excedente ao estabelecido pela Lei n Âº 12.651, de 2012;</li><li>Ãrea de PreservaÃ§Ã£o Permanente;</li><li>Ãreas de PreservaÃ§Ã£o Permanente no percentual da Ã¡rea de Reserva Legal;</li><li>sobreposiÃ§Ã£o de perÃ­metro de um imÃ³vel rural com o perÃ­metro de outro imÃ³vel rural;</li><li>sobreposiÃ§Ã£o de Ã¡reas delimitadas que identificam o remanescente de vegetaÃ§Ã£o nativa com as Ã¡reas que identificam o uso consolidado do imÃ³vel rural;</li><li>sobreposiÃ§Ã£o de Ã¡reas que identificam o uso consolidado situado em Ãreas de PreservaÃ§Ã£o Permanente do imÃ³vel rural com Unidades de ConservaÃ§Ã£o;</li><li>sobreposiÃ§Ã£o parcial ou total, de Ã¡rea do imÃ³vel rural com Terras IndÃ­genas;</li><li>sobreposiÃ§Ã£o do imÃ³vel rural com Ã¡reas embargadas, pelo Ã³rgÃ£o competente; e</li><li>exclusÃ£o das Ã¡reas de servidÃ£o administrativa da Ã¡rea total, para efeito do cÃ¡lculo da Ã¡rea de Reserva Legal.</li></ol><p>No processo de anÃ¡lise das informaÃ§Ãµes declaradas no CAR, o Ã³rgÃ£o competente pode realizar vistorias no imÃ³vel rural, bem como solicitar do proprietÃ¡rio ou possuidor rural a revisÃ£o das informaÃ§Ãµes declaradas e os respectivos documentos comprobatÃ³rios. Esses documentos relativos Ã s informaÃ§Ãµes solicitadas poderÃ£o ser fornecidos por meio digital.</p><p>O CAR poderÃ¡ dispor de mecanismos de anÃ¡lise que permitam:</p><ol><li>elaborar o termo de compromisso e os atos decorrentes das sanÃ§Ãµes administrativas previstas nos Â§Â§ 4 Âº e 5 Âº do art. 59 da Lei n Âº 12.651, de 2012; e</li><li>avaliar as declaraÃ§Ãµes de Ã¡reas de uso consolidado antes de 22 de julho de 2008, para que possam ser dirimidas quaisquer dÃºvidas sobre uso e destinaÃ§Ã£o dessas Ã¡reas.</li></ol><p>As informaÃ§Ãµes dos imÃ³veis rurais inscritos no Programa Mais Ambiente atÃ© 18 de outubro de 2012 poderÃ£o ser migradas para o CAR. As inscriÃ§Ãµes que migrarem serÃ£o encaminhadas para anÃ¡lise nos Ã³rgÃ£os competentes que poderÃ£o solicitar complementaÃ§Ã£o ou retificaÃ§Ã£o dos dados dos imÃ³veis, para fins de efetivaÃ§Ã£o de inscriÃ§Ã£o. CaberÃ¡ aos entes federativos estabelecer os prazos para complementaÃ§Ã£o ou retificaÃ§Ã£o dos dados ou informaÃ§Ãµes.</p>"
                }, {
                    id: "39",
                    categoria: "retificacaoCar",
                    pergunta: "Como Ã© feita a anÃ¡lise da localizaÃ§Ã£o da Ã¡rea de Reserva Legal?",
                    resposta: "<p>A anÃ¡lise da localizaÃ§Ã£o da Ã¡rea de Reserva Legal dos imÃ³veis rurais no CAR Ã© feita com base nas informaÃ§Ãµes declaradas no CAR referentes Ã : identificaÃ§Ã£o do perÃ­metro da localizaÃ§Ã£o da Reserva Legal, dos remanescentes de vegetaÃ§Ã£o nativa e, caso existam, das Ã¡reas consolidadas, ou seja, das Ã¡reas que foram desmatadas antes 22 de julho de 2008.</p><p>Iniciada a anÃ¡lise dos dados, o proprietÃ¡rio ou possuidor do imÃ³vel rural nÃ£o poderÃ¡ alterar ou retificar as informaÃ§Ãµes cadastradas atÃ© o encerramento dessa etapa, exceto nos casos de notificaÃ§Ãµes.</p><p>No processo de anÃ¡lise da Reserva Legal declarada no CAR, o Ã³rgÃ£o competente poderÃ¡ realizar vistorias no imÃ³vel rural, bem como solicitar do proprietÃ¡rio ou possuidor rural a revisÃ£o das informaÃ§Ãµes declaradas e os respectivos documentos comprobatÃ³rios. Esses documentos relativos Ã s informaÃ§Ãµes solicitadas poderÃ£o ser fornecidos por meio digital.</p><p>A Reserva Legal deve ser conservada com cobertura de vegetaÃ§Ã£o nativa pelo proprietÃ¡rio do imÃ³vel rural, possuidor ou ocupante a qualquer tÃ­tulo, pessoa fÃ­sica ou jurÃ­dica, de direito pÃºblico ou privado.</p><p>A anÃ¡lise do Ã³rgÃ£o competente observarÃ¡ a localizaÃ§Ã£o da Reserva Legal, bem como a manutenÃ§Ã£o da proporcionalidade da Reserva Legal instituÃ­da dos imÃ³veis rurais decorrentes do desmembramento ou fracionamento.</p><p>Para as Ã¡reas de Reserva Legal com cobertura de vegetaÃ§Ã£o nativa que nÃ£o se enquadrarem nos percentuais mÃ­nimos, em relaÃ§Ã£o Ã  Ã¡rea do imÃ³vel, dispostos no art.12 da Lei 12.651/2012, as quais foram desmatadas atÃ© 22 de julho de 2008, poderÃ£o regularizar-se mediante disposto nos artigos 66, 67 e 68 da 12.651/2012.</p>"
                }, {
                    id: "40",
                    categoria: "retificacaoCar",
                    pergunta: "Em caso de notificaÃ§Ã£o pelo Ã³rgÃ£o estadual competente, como proceder?",
                    resposta: "<p>Em caso de notificaÃ§Ã£o pelo Ã³rgÃ£o estadual competente as pendencias e recomendaÃ§Ãµes indicadas devem ser atendidas para a conclusÃ£o do processo de anÃ¡lise.</p><p>Nos estados que adotam o SICAR, o detentor do imÃ³vel, ao ser notificado, recebe uma cÃ³pia digital desta notificaÃ§Ã£o na Central do ProprietÃ¡rio/Possuidor, na aba â€œMensagensâ€, com emissÃ£o de alerta na â€œPÃ¡gina Inicialâ€ indicando, inclusive, o prazo para o atendimento. Para visualizar o conteÃºdo da notificaÃ§Ã£o, acesse a aba â€œMensagensâ€, clique na notificaÃ§Ã£o e siga as instruÃ§Ãµes indicadas pelo sistema. Caso a notificaÃ§Ã£o solicite apresentaÃ§Ã£o de documentos, esses poderÃ£o ser enviados por meio da aba â€œEnvio de Documentosâ€. Caso solicite retificaÃ§Ã£o do CAR, esse procedimento poderÃ¡ ser efetuado por meio da aba â€œRetificaÃ§Ã£oâ€. Outra forma de atender Ã  notificaÃ§Ã£o Ã© pelo alerta emitido na â€œPÃ¡gina Inicialâ€, bastando clicar no botÃ£o â€œatenderâ€ para ser redirecionado para aba pertinente (â€œEnvio de Documentosâ€ ou â€œRetificaÃ§Ã£oâ€).</p>"
                }, {
                    id: "41",
                    categoria: "retificacaoCar",
                    pergunta: "A partir de que momento comeÃ§a a ser contado o prazo para atendimento da notificaÃ§Ã£o emitida pelo Ã³rgÃ£o competente?",
                    resposta: "<p>O prazo para atendimento comeÃ§a a ser contado a partir do recebimento, pelo proprietÃ¡rio/possuidor ou representante legal, da notificaÃ§Ã£o emitida pelo Ã³rgÃ£o estadual competente. A entrega da notificaÃ§Ã£o serÃ¡ feita de acordo com os procedimentos do Ã³rgÃ£o estadual competente, podendo ser: via correio, presencialmente, publicaÃ§Ã£o no DiÃ¡rio Oficial ou outro instrumento utilizado pelo estado. O prazo para atendimento Ã© definido pelo Ã³rgÃ£o estadual competente e constarÃ¡ na notificaÃ§Ã£o.</p><p>Para mais informaÃ§Ãµes, busque orientaÃ§Ãµes junto ao Ã³rgÃ£o estadual competente. Contatos disponÃ­veis em <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "42",
                    categoria: "retificacaoCar",
                    pergunta: "O que Ã© a Central do ProprietÃ¡rio/Possuidor?",
                    resposta: "<p>A Central do ProprietÃ¡rio/Possuidor Ã© o canal de comunicaÃ§Ã£o entre o Ã³rgÃ£o estadual responsÃ¡vel pelo CAR e o proprietÃ¡rio/ possuidor ou o representante legal declarado no preenchimento do cadastro. </p><p>a Central o usuÃ¡rio obtÃ©m o arquivo de extensÃ£o â€œ.carâ€, a segunda via do Recibo de InscriÃ§Ã£o do ImÃ³vel Rural no CAR, acompanha a inscriÃ§Ã£o e a anÃ¡lise, acessa o histÃ³rico das mensagens e notificaÃ§Ãµes relacionadas aos imÃ³veis cadastrados em seu CPF/CNPJ. AlÃ©m disso, o usuÃ¡rio pode retificar as informaÃ§Ãµes declaradas no CAR e atender Ã s pendÃªncias relacionadas Ã  envio de documentos e retificaÃ§Ãµes identificadas na etapa de anÃ¡lise.</p><p>Para acessar esse ambiente, o proprietÃ¡rio/ possuidor ou o representante legal deve cadastrar-se por meio do link <a href='http://www.car.gov.br/#/central/acesso'>http://www.car.gov.br/#/central/acesso</a>.</p>"
                }, {
                    id: "43",
                    categoria: "retificacaoCar",
                    pergunta: "Quem pode se cadastrar na Central do ProprietÃ¡rio/Possuidor? ",
                    resposta: "<p>O cadastro na Central do ProprietÃ¡rio/Possuidor cabe apenas aos proprietÃ¡rios, possuidores ou representantes legais declarados e vinculados ao imÃ³vel.</p>"
                }, {
                    id: "44",
                    categoria: "retificacaoCar",
                    pergunta: "Como se cadastrar na Central do ProprietÃ¡rio/Possuidor?",
                    resposta: "<p>O cadastro junto Ã  Central do ProprietÃ¡rio/Possuidor se dÃ¡ por meio do link <a href='http://www.car.gov.br/#/central/acesso'>http://www.car.gov.br/#/central/acesso</a>. </p><p>Para cadastrar-se neste ambiente, Ã© necessÃ¡rio informar no campo â€œNÃ£o tenho cadastroâ€ o nÃºmero do Recibo de InscriÃ§Ã£o do ImÃ³vel Rural no CAR (e nÃ£o o nÃºmero do protocolo de preenchimento) e respectivo CPF ou CNPJ declarado no cadastro enviado. Em seguida, serÃ£o solicitadas algumas informaÃ§Ãµes e o e-mail para envio de senha provisÃ³ria. Caso o e-mail com a senha provisÃ³ria nÃ£o seja recebido, Ã© necessÃ¡ria uma nova tentativa em 24 horas. Ao acessar o e-mail enviado serÃ¡ solicitado ao usuÃ¡rio a definiÃ§Ã£o de uma nova senha, efetivando, assim, o cadastramento na Central.</p>"
                }, {
                    id: "45",
                    categoria: "retificacaoCar",
                    pergunta: "Como acessar a Central do ProprietÃ¡rio/Possuidor do SICAR?",
                    resposta: "<p>O acesso a Central do ProprietÃ¡rio/Possuidor do SICAR se dÃ¡ por meio do link <a href='http://www.car.gov.br/#/central/acesso'>http://www.car.gov.br/#/central/acesso</a> e somente pode ser feito pelo proprietÃ¡rio/possuidor ou o representante legal, informando no campo â€œJÃ¡ tenho cadastroâ€ o CPF ou CNPJ declarado no cadastro enviado e a senha.</p>"
                }, {
                    id: "46",
                    categoria: "retificacaoCar",
                    pergunta: "Como recuperar o arquivo â€œ.carâ€ e a segunda via do Recibo de InscriÃ§Ã£o?",
                    resposta: "<p>Ã‰ possÃ­vel recuperar o arquivo â€œ.carâ€ e a segunda via do Recibo de InscriÃ§Ã£o por meio da Central do ProprietÃ¡rio/Possuidor, opÃ§Ãµes â€œBaixar o arquivo .CARâ€ ou â€œRecibo de inscriÃ§Ã£oâ€.</p>"
                }, {
                    id: "47",
                    categoria: "retificacaoCar",
                    pergunta: "Como recuperar a senha da Central do ProprietÃ¡rio/Possuidor do SICAR?",
                    resposta: "<p>Para recuperar a senha da Central do ProprietÃ¡rio/Possuidor do SICAR Ã© necessÃ¡rio que seja informado CPF/CNPJ e e-mail cadastrados na Central, em <a href='http://car.gov.br/#/recuperarSenha'>http://car.gov.br/#/recuperarSenha</a>. Uma senha provisÃ³ria serÃ¡ enviada pelo SICAR para o e-mail cadastrado na Central e, ao ser utilizada no primeiro acesso, serÃ¡ solicitado ao usuÃ¡rio a definiÃ§Ã£o de uma nova senha. Destaca-se que a senha antiga solicitada nesse momento Ã© aquela que foi enviada por e-mail.</p><p>Caso o proprietÃ¡rio/possuidor ou representante legal nÃ£o tenha mais acesso ao e-mail cadastrado na Central, serÃ¡ necessÃ¡rio procurar o Ã³rgÃ£o estadual competente e solicitar a alteraÃ§Ã£o para o e-mail atual. Contatos disponÃ­veis em <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "48",
                    categoria: "retificacaoCar",
                    pergunta: "Como recuperar o nÃºmero do Recibo de InscriÃ§Ã£o no CAR tendo apenas o nÃºmero de Protocolo de Preenchimento?",
                    resposta: "<p>Caso o usuÃ¡rio tenha somente o nÃºmero do Protocolo de Preenchimento, poderÃ¡ consultar o nÃºmero do Recibo, no SICAR, por meio do link <a href='http://car.gov.br/#/consultar'>http://car.gov.br/#/consultar</a>, utilizando o nÃºmero do Protocolo.</p>"
                }, {
                    id: "49",
                    categoria: "retificacaoCar",
                    pergunta: "Como retificar a inscriÃ§Ã£o de um CAR?",
                    resposta: "<p>A retificaÃ§Ã£o do cadastro deve ser feita por meio da aba â€œRetificarâ€, no MÃ³dulo de Cadastro. Informe o nÃºmero do Recibo de InscriÃ§Ã£o emitido pelo SICAR, importe o arquivo .â€carâ€, e realize as correÃ§Ãµes pertinentes. Caso nÃ£o possua o arquivo â€œ.carâ€, o mesmo poderÃ¡ ser recuperado por meio da Central do ProprietÃ¡rio-Possuidor. AtenÃ§Ã£o para nÃ£o utilizar o nÃºmero de Protocolo de preenchimento. </p><p>ApÃ³s a conclusÃ£o do preenchimento da declaraÃ§Ã£o retificadora, o arquivo â€œ.carâ€ deverÃ¡ ser enviado para o SICAR por meio da Central do ProprietÃ¡rio/Possuidor, aba â€œRetificarâ€.</p><p>A retificaÃ§Ã£o nÃ£o Ã© possÃ­vel enquanto o cadastro estiver em anÃ¡lise, a nÃ£o ser que o Ã³rgÃ£o estadual competente notifique o proprietÃ¡rio/possuidor a retificar o CAR.</p>"
                }, {
                    id: "50",
                    categoria: "retificacaoCar",
                    pergunta: "Por que ao tentar cadastrar o usuÃ¡rio na Central do ProprietÃ¡rio / Possuidor apareceu a mensagem â€œO seu registro estÃ¡ bloqueado por ter respondido incorretamente as perguntas 3 vezes. Tente novamente apÃ³s o perÃ­odo de 24 horas.â€, mesmo os dados tendo sido informados conforme a documentaÃ§Ã£o existente? ",
                    resposta: "<p>Ao proceder com o cadastro de um usuÃ¡rio na Central do ProprietÃ¡rio/Possuidor sÃ£o realizadas perguntas de seguranÃ§a referentes a dados pessoais do proprietÃ¡rio ou possuidor. Quando os dados informados divergem daqueles informados no CAR, o cadastramento na Central Ã© bloqueado por 24 horas.</p><p>Em geral, esta situaÃ§Ã£o Ã© gerada pela declaraÃ§Ã£o equivocada da data de nascimento no CAR, que Ã© uma das informaÃ§Ãµes de seguranÃ§a necessÃ¡ria para efetivar o cadastro na Central do ProprietÃ¡rio/Possuidor.</p>"
                }, {
                    id: "51",
                    categoria: "retificacaoCar",
                    pergunta: "Como proceder caso alguma informaÃ§Ã£o tenha sido declarada errada no CAR?",
                    resposta: "<p>Caso alguma informaÃ§Ã£o tenha sido declarada errada no CAR Ã© necessÃ¡rio realizar a retificaÃ§Ã£o do cadastro. Para tanto, faz-se necessÃ¡rio conhecer a informaÃ§Ã£o que foi declarada no CAR do imÃ³vel, a fim de que seja possÃ­vel criar o cadastro na Central do ProprietÃ¡rio/Possuidor. Caso o proprietÃ¡rio, possuidor ou representante legal nÃ£o possua o nÃºmero do Recibo de InscriÃ§Ã£o do ImÃ³vel Rural no CAR ou o nÃºmero do Protocolo de preenchimento para a inscriÃ§Ã£o no CAR, deve buscar junto ao Ã³rgÃ£o estadual competente orientaÃ§Ã£o em relaÃ§Ã£o aos procedimentos necessÃ¡rios para obter os dados constantes no CAR que foram declarados erroneamente. </p>"
                }, {
                    id: "52",
                    categoria: "retificacaoCar",
                    pergunta: "Como Ã© feito o acompanhamento dos resultados da anÃ¡lise pela Central do ProprietÃ¡rio/Possuidor?",
                    resposta: "<p>O acompanhamento da anÃ¡lise do CAR pela Central do ProprietÃ¡rio/Possuidor, link http://www.car.gov.br/#/central/acesso, pode ser realizado de diversas formas.</p><p>Ao acessar a Central do ProprietÃ¡rio/Possuidor o usuÃ¡rio poderÃ¡ clicar na opÃ§Ã£o â€œDetalhes do ImÃ³velâ€, a qual apresenta a aba â€œFicha do ImÃ³velâ€ com as informaÃ§Ãµes declaradas do cadastrante, do imÃ³vel, do domÃ­nio, da documentaÃ§Ã£o, do geo e das informaÃ§Ãµes adicionais, alÃ©m de apresentar a origem (cÃ³digo e data do protocolo de inscriÃ§Ã£o) e o histÃ³rico (data, hora, situaÃ§Ã£o do cadastro e origem) das informaÃ§Ãµes declaradas; e a aba â€œComparar RetificaÃ§Ãµesâ€ com o histÃ³rico de todas as retificaÃ§Ãµes realizadas.</p><p>Na aba â€œPÃ¡gina Inicialâ€ da Central do ProprietÃ¡rio/Possuidor, o usuÃ¡rio pode acompanhar a anÃ¡lise do CAR por meio do Demonstrativo da SituaÃ§Ã£o do CAR, o qual apresenta informaÃ§Ãµes do cadastro quanto Ã  situaÃ§Ã£o (ativo, pendente ou cancelado); Ã  condiÃ§Ã£o (aguardando anÃ¡lise, em anÃ¡lise, analisado com pendÃªncias); e Ã  situaÃ§Ã£o da Reserva Legal (nÃ£o analisada, aprovada e nÃ£o aprovada).</p><p>Na aba â€œCentral de Mensagensâ€ da Central do ProprietÃ¡rio/Possuidor, o usuÃ¡rio pode acompanhar a anÃ¡lise do CAR por meio das mensagens recebidas com data, hora e assunto. Essas mensagens podem ser referentes:</p><ul><li>Ã  anÃ¡lise automÃ¡tica do SICAR, antes mesmo do inÃ­cio da anÃ¡lise pelo tÃ©cnico (por exemplo: â€œindÃ­cio de sobreposiÃ§Ã£o com Unidade de ConservaÃ§Ã£oâ€);</li><li>ao inÃ­cio e ao fim da anÃ¡lise pela equipe tÃ©cnica; e</li><li>a notificaÃ§Ãµes emitidas pela equipe tÃ©cnica responsÃ¡vel pela anÃ¡lise.</li></ul><p>Na aba â€œEnvio de documentosâ€ na Central do ProprietÃ¡rio/Possuidor, o usuÃ¡rio poderÃ¡ acompanhar os documentos pendentes de envio, enviados ou justificados, solicitados pelo tÃ©cnico para realizar a anÃ¡lise do CAR.</p>"
                }, {
                    id: "53",
                    categoria: "retificacaoCar",
                    pergunta: "Como posso obter os documentos derivados da anÃ¡lise?",
                    resposta: "<p>Ao acessar a Central do ProprietÃ¡rio/Possuidor, na aba â€œCentral de Mensagensâ€ o usuÃ¡rio, ao clicar no assunto â€œseu imÃ³vel foi analisadoâ€ serÃ¡ aberta uma mensagem informando que o seu imÃ³velÂ foi analisado pela equipe tÃ©cnica e que o usuÃ¡rio pode acessar o â€œRelatÃ³rio de AnÃ¡lise TÃ©cnicaâ€, anexo em pdf., documento este composto pela situaÃ§Ã£o e condiÃ§Ã£o do processo, resultante da anÃ¡lise, bem como, caso aplicÃ¡vel, suas inconsistÃªncias, recomendaÃ§Ãµes e observaÃ§Ãµes para atendimento. Na aba â€œCentral de Mensagensâ€ o usuÃ¡rio, ao clicar no assunto â€œNotificaÃ§Ã£oâ€, serÃ¡ aberta uma mensagem informando o prazo para atendimento da notificaÃ§Ã£o (em dias) e disponibilizando o documento da notificaÃ§Ã£o para download, anexo em pdf.</p>"
                }, {
                    id: "54",
                    categoria: "retificacaoCar",
                    pergunta: "Que tipo de mensagens receberei na Central do ProprietÃ¡rio/Possuidor?",
                    resposta: "<p>Na aba â€œCentral de Mensagensâ€ da Central do ProprietÃ¡rio/Possuidor, o usuÃ¡rio poderÃ¡ acompanhar as mensagens enviadas pelo SICAR, com data, hora e assunto. Estas mensagens podem ser referentes Ã  anÃ¡lise automÃ¡tica do SICAR antes mesmo do inÃ­cio da anÃ¡lise pelo tÃ©cnico (como por exemplo, â€œindÃ­cio de sobreposiÃ§Ã£o com Unidade de ConservaÃ§Ã£oâ€); ao inÃ­cio e ao fim da anÃ¡lise pela equipe tÃ©cnica; bem como Ã s notificaÃ§Ãµes, caso houver.</p>"
                }, {
                    id: "55",
                    categoria: "retificacaoCar",
                    pergunta: "Como posso gerenciar meu representante legal pela Central do ProprietÃ¡rio/Possuidor?",
                    resposta: "<p>Na aba â€œGerenciar VÃ­nculosâ€ da Central do ProprietÃ¡rio/Possuidor, o usuÃ¡rio poderÃ¡ gerenciar os dados do representante legal, ou seja, vincular ou desvincular o representante legal de determinado CAR.</p>"
                }, {
                    id: "56",
                    categoria: "regularizacao",
                    pergunta: "O que Ã© a RegularizaÃ§Ã£o Ambiental do imÃ³vel rural e onde formalizÃ¡-la?",
                    resposta: "<p>A RegularizaÃ§Ã£o Ambiental do imÃ³vel rural Ã© o conjunto de atividades desenvolvidas e implementadas que visem atender ao disposto na legislaÃ§Ã£o ambiental e, principalmente, relacionadas com a manutenÃ§Ã£o e recuperaÃ§Ã£o de Ãreas de PreservaÃ§Ã£o Permanente, de Reserva Legal e de uso restrito, e Ã  compensaÃ§Ã£o da Reserva Legal. A inscriÃ§Ã£o do imÃ³vel no CAR, junto ao Ã³rgÃ£o estadual competente, Ã© o primeiro passo para obtenÃ§Ã£o da regularidade ambiental. </p><p>Identificada na inscriÃ§Ã£o a existÃªncia de passivo ambiental, o proprietÃ¡rio ou possuidor de imÃ³vel rural poderÃ¡ solicitar de imediato a adesÃ£o ao Programa de RegularizaÃ§Ã£o Ambiental - PRA, sendo que, com base no requerimento de adesÃ£o ao PRA, o Ã³rgÃ£o estadual competente convocarÃ¡ o proprietÃ¡rio ou possuidor para assinar o termo de compromisso.</p>"
                }, {
                    id: "57",
                    categoria: "regularizacao",
                    pergunta: "O que Ã© o Programa de RegularizaÃ§Ã£o Ambiental â€“ PRA e quem pode aderir?",
                    resposta: "<p>Os Programas de RegularizaÃ§Ã£o Ambiental â€“ PRAs compreendem o conjunto de aÃ§Ãµes ou iniciativas a serem desenvolvidas por proprietÃ¡rios e posseiros rurais com o objetivo de adequar e promover a regularizaÃ§Ã£o ambiental referentes Ã  supressÃ£o irregular de vegetaÃ§Ã£o nativa nas Ã¡reas consolidadas (Ã¡reas em uso que foram desmatadas atÃ© 22 de julho de 2008) em Ãreas de PreservaÃ§Ã£o Permanente, de Reserva Legal e de uso restrito. Cabe ressaltar que a inscriÃ§Ã£o no CAR Ã© condiÃ§Ã£o obrigatÃ³ria para a adesÃ£o ao PRA. </p><p>Identificada na inscriÃ§Ã£o a existÃªncia de passivo ambiental, o proprietÃ¡rio ou possuidor de imÃ³vel rural poderÃ¡ solicitar de imediato a adesÃ£o ao Programa de RegularizaÃ§Ã£o Ambiental - PRA, sendo que, com base no requerimento de adesÃ£o ao PRA, o Ã³rgÃ£o estadual competente convocarÃ¡ o proprietÃ¡rio ou possuidor para assinar o termo de compromisso.</p><p>Mais informaÃ§Ãµes sobre o PRA podem ser obtidas junto ao Ã³rgÃ£o estadual competente. Contatos disponÃ­veis em <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "58",
                    categoria: "regularizacao",
                    pergunta: "O que Ã© o Termo de Compromisso de adesÃ£o ao PRA?",
                    resposta: "<p>O Termo de Compromisso Ã© o documento formal de adesÃ£o ao Programa de RegularizaÃ§Ã£o Ambiental â€“ PRA, com os compromissos de manter, recuperar ou recompor Ãreas de PreservaÃ§Ã£o Permanente, Reservas Legais, e de uso restrito do imÃ³vel rural, ou ainda de compensar Ãreas de Reserva Legal. Com base no requerimento de adesÃ£o ao PRA, o Ã³rgÃ£o estadual competente convocarÃ¡ o proprietÃ¡rio ou o possuidor para assinar o Termo de Compromisso, que constituirÃ¡ tÃ­tulo executivo extrajudicial. </p><p>Desde a assinatura atÃ© quando estiver sendo cumprindo o Termo de Compromisso, estarÃ£o suspensas as sanÃ§Ãµes administrativas e a punibilidade de crimes e infraÃ§Ãµes cometidos antes de 22 de julho de 2008, quanto Ã  supressÃ£o irregular de vegetaÃ§Ã£o nativa em APP, reserva legal e Ã¡reas de uso restrito. A punibilidade fica extinta com a efetiva regularizaÃ§Ã£o ambiental atestada pelo Ã³rgÃ£o estadual competente assegurando que os compromissos firmados foram cumpridos.</p>"
                }, {
                    id: "59",
                    categoria: "regularizacao",
                    pergunta: "Quais sÃ£o as alternativas de regularizaÃ§Ã£o para o imÃ³vel rural com dÃ©ficit de vegetaÃ§Ã£o nativa para fins de cumprimento da Reserva Legal?",
                    resposta: "<p>O imÃ³vel rural que detinha, em 22 de julho de 2008, Ã¡rea de Reserva Legal em extensÃ£o inferior ao estabelecido ao exigido em lei poderÃ¡ regularizar sua situaÃ§Ã£o adotando as seguintes alternativas, isolada ou conjuntamente: </p><ul><li>recompor a Reserva Legal; </li><li>permitir a regeneraÃ§Ã£o natural da vegetaÃ§Ã£o na Ã¡rea de Reserva Legal;</li><li>compensar a Reserva Legal.</li></ul><p>Esta regularizaÃ§Ã£o poderÃ¡ ser feita independentemente da adesÃ£o ao Programa de RegularizaÃ§Ã£o Ambiental â€“ PRA.</p>"
                }, {
                    id: "60",
                    categoria: "regularizacao",
                    pergunta: "Como pode ser feita a recomposiÃ§Ã£o da vegetaÃ§Ã£o nativa em Ã¡reas de preservaÃ§Ã£o permanente, de Reserva Legal, e de uso restrito?",
                    resposta: "<p>A recomposiÃ§Ã£o da vegetaÃ§Ã£o nativa em Ãreas de PreservaÃ§Ã£o Permanente, de Reserva Legal e de uso restrito poderÃ¡ ser feita, isolada ou conjuntamente, pelos seguintes mÃ©todos</p><ul><li>conduÃ§Ã£o de regeneraÃ§Ã£o natural de espÃ©cies nativas;</li><li>plantio de espÃ©cies nativas;</li><li>plantio de espÃ©cies nativas conjugado com a conduÃ§Ã£o da regeneraÃ§Ã£o natural de espÃ©cies nativas;</li></ul><p>No caso das Ã¡reas de preservaÃ§Ã£o permanente de imÃ³veis rurais de atÃ© 4 mÃ³dulos fiscais e das Ã¡reas de Reserva Legal, a recomposiÃ§Ã£o tambÃ©m poderÃ¡ ser feita por meio do plantio intercalado de espÃ©cies lenhosas, perenes ou de ciclo longo, exÃ³ticas com nativas de ocorrÃªncia regional, em atÃ© 50% (cinquenta por cento) da Ã¡rea total a ser recomposta.</p><p>No caso da Reserva Legal, a recomposiÃ§Ã£o deverÃ¡ atender os critÃ©rios estipulados pelo Ã³rgÃ£o estadual competente e ser concluÃ­da em atÃ© 20 (vinte) anos, abrangendo, a cada 2 (dois) anos, no mÃ­nimo 1/10 (um dÃ©cimo) da Ã¡rea total necessÃ¡ria Ã  sua complementaÃ§Ã£o. A recomposiÃ§Ã£o das Ã¡reas de reserva legal desmatadas irregularmente apÃ³s 22/07/2008 deverÃ¡ ser iniciada a partir da publicaÃ§Ã£o a Lei nÂº 12.651, dia 25 de maio de 2012.</p><p>O proprietÃ¡rio ou possuidor de imÃ³vel rural que optar por recompor a Reserva Legal terÃ¡ direito a sua exploraÃ§Ã£o econÃ´mica. </p>"
                }, {
                    id: "61",
                    categoria: "regularizacao",
                    pergunta: "Como pode ser feita a compensaÃ§Ã£o das Ã¡reas consolidadas em Reserva Legal?",
                    resposta: "<p>A compensaÃ§Ã£o de Reserva Legal poderÃ¡ ser feita por meio de:</p><ul><li>aquisiÃ§Ã£o de Cota de Reserva Ambiental - CRA; </li><li>arrendamento de Ã¡rea sob regime de servidÃ£o ambiental ou Reserva Legal; </li><li>doaÃ§Ã£o ao poder pÃºblico de Ã¡rea localizada no interior de Unidade de ConservaÃ§Ã£o de domÃ­nio pÃºblico pendente de regularizaÃ§Ã£o fundiÃ¡ria; </li><li>cadastramento de outra Ã¡rea equivalente e excedente Ã  Reserva Legal, em imÃ³vel de mesma titularidade ou adquirida em imÃ³vel de terceiro, com vegetaÃ§Ã£o nativa estabelecida, em regeneraÃ§Ã£o ou recomposiÃ§Ã£o, desde que localizada no mesmo bioma.</li></ul><p>NÃ£o poderÃ£o ser compensadas Ã¡reas de Reserva Legal, ou Ã¡reas de remanescentes de vegetaÃ§Ã£o nativa que compÃµem a Ã¡rea mÃ­nima que deve ser constituÃ­da como reserva legal, caso as mesmas tenham sido desmatadas depois de 22/07/2008.</p>"
                }, {
                    id: "62",
                    categoria: "regularizacao",
                    pergunta: "Qual Ã© o prazo para adesÃ£o ao PRA?",
                    resposta: "A adesÃ£o ao PRA deve ser requerida no prazo estipulado para inscriÃ§Ã£o no CAR, atÃ© 31 de dezembro de 2017. "
                }, {
                    id: "63",
                    categoria: "regularizacao",
                    pergunta: "Qual Ã© a diferenÃ§a ente a RegularizaÃ§Ã£o FundiÃ¡ria e RegularizaÃ§Ã£o Ambiental?",
                    resposta: "<p>A regularizaÃ§Ã£o fundiÃ¡ria consiste em processo de intervenÃ§Ã£o pÃºblica que objetiva legalizar a permanÃªncia de populaÃ§Ã£o que reside em Ã¡reas ocupadas em desconformidade com a lei. SÃ£o quatro as modalidades de regularizaÃ§Ã£o fundiÃ¡ria previstas na legislaÃ§Ã£o brasileira: </p><ul><li>regularizaÃ§Ã£o fundiÃ¡ria de interesse social (Lei no 11.977/2009);</li><li>regularizaÃ§Ã£o fundiÃ¡ria de interesse especÃ­fico (Lei no 11.977/2009);</li><li>regularizaÃ§Ã£o fundiÃ¡ria inominada ou de antigos loteamentos (Lei no 11.977, art. 71); e</li><li>regularizaÃ§Ã£o fundiÃ¡ria em imÃ³veis do patrimÃ´nio pÃºblico (Lei no 11.481/2007).</li></ul><p>JÃ¡ a RegularizaÃ§Ã£o Ambiental estÃ¡ relacionada com atividades desenvolvidas e implementadas no imÃ³vel rural que visem atender ao disposto na legislaÃ§Ã£o ambiental e, de forma prioritÃ¡ria, Ã  manutenÃ§Ã£o e recuperaÃ§Ã£o de Ã¡reas de preservaÃ§Ã£o permanente, de reserva legal e de uso restrito, e Ã  compensaÃ§Ã£o da reserva legal, quando couber.</p><p>Importante compreender que a regularizaÃ§Ã£o ambiental nÃ£o implica em direitos fundiÃ¡rios. A inscriÃ§Ã£o do imÃ³vel rural no CAR nÃ£o serÃ¡ considerada tÃ­tulo para fins de reconhecimento de direito de propriedade.</p>"
                }, {
                    id: "64",
                    categoria: "regularizacao",
                    pergunta: "Ã‰ possÃ­vel regularizar sua situaÃ§Ã£o, independentemente da adesÃ£o ao PRA?",
                    resposta: "<p>Sim. A regularizaÃ§Ã£o ambiental mediante termo de compromisso Ã© obrigatÃ³ria a todos os imÃ³veis rurais que nÃ£o atendam aos parÃ¢metros estabelecidos pelo CÃ³digo Florestal, Lei nÂº 12.651/2012, referentes Ã s Ã¡reas de preservaÃ§Ã£o permanente, de reserva legal, e de uso restrito, e independe da adesÃ£o aos Programas de RegularizaÃ§Ã£o Ambiental â€“ PRA, que Ã© opcional.</p>"
                }, {
                    id: "65",
                    categoria: "compensacaoReserva",
                    pergunta: "O que Ã© a CompensaÃ§Ã£o de Reserva Legal?",
                    resposta: "<p>A compensaÃ§Ã£o de RL estÃ¡ contida no CÃ³digo Florestal e prevÃª que os proprietÃ¡rios rurais que desmataram a sua RL, antes de 22 de julho de 2008, alÃ©m do permitido pela lei, nÃ£o precisam reflorestar e/ou regenerar a Ã¡rea desmatada para se regularizar e podem optar por compensar o dÃ©ficit de RL em outra propriedade, ou gleba rural. Esse mecanismo pode ser adotado independentemente da adesÃ£o ao Programa de RegularizaÃ§Ã£o Ambiental â€“ PRA, devendo ser aprovado pelo Ã³rgÃ£o estadual competente.</p>"
                }, {
                    id: "66",
                    categoria: "compensacaoReserva",
                    pergunta: "Quais as modalidades de compensaÃ§Ã£o de RL existentes?",
                    resposta: "<p>A compensaÃ§Ã£o poderÃ¡ ser realizada por meio das seguintes modalidades:</p><ul><li>aquisiÃ§Ã£o de Cota de Reserva Ambiental - CRA;</li><li>arrendamento de Ã¡rea sob regime de servidÃ£o ambiental ou reserva legal;</li><li>doaÃ§Ã£o ao poder pÃºblico de Ã¡rea localizada no interior de Unidade de ConservaÃ§Ã£o de domÃ­nio pÃºblico pendente de regularizaÃ§Ã£o fundiÃ¡ria;</li><li>cadastramento de outra Ã¡rea equivalente e excedente Ã  Reserva Legal em imÃ³vel de mesma titularidade ou adquirida em imÃ³vel de terceiro, com vegetaÃ§Ã£o nativa, em regeneraÃ§Ã£o ou recomposiÃ§Ã£o.</li></ul>"
                }, {
                    id: "67",
                    categoria: "compensacaoReserva",
                    pergunta: "Quais sÃ£o os critÃ©rios para a realizaÃ§Ã£o da compensaÃ§Ã£o de Reserva Legal?",
                    resposta: "<p>As Ã¡reas utilizadas para a compensaÃ§Ã£o de RL deverÃ£o: ser equivalentes em extensÃ£o Ã  Ã¡rea da Reserva Legal a ser compensada, estar localizadas no mesmo bioma da Ã¡rea de Reserva Legal a ser compensada, e, se fora do Estado, estar localizadas em Ã¡reas identificadas como prioritÃ¡rias pela UniÃ£o ou pelos Estados. </p><p>Importante destacar que as medidas de compensaÃ§Ã£o de RL nÃ£o poderÃ£o ser utilizadas como forma de viabilizar a conversÃ£o de novas Ã¡reas para uso alternativo do solo. SÃ³ podem compensar RL aqueles que desmataram a sua RL atÃ© 22 de julho de 2008.</p><p>A CompensaÃ§Ã£o de Reserva Legal para fins de regularizaÃ§Ã£o ambiental deve ser aprovada pelo Ã³rgÃ£o estadual competente; contatos disponÃ­veis no link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "68",
                    categoria: "compensacaoReserva",
                    pergunta: "O que Ã© a Cota de Reserva Ambiental?",
                    resposta: "<p>A Cota de Reserva Ambiental (CRA) Ã© um tÃ­tulo nominativo representativo de Ã¡rea com vegetaÃ§Ã£o nativa, existente ou em processo de recuperaÃ§Ã£o, que pode ser utilizado, onerosa ou gratuitamente, para compensar a Reserva Legal de imÃ³veis rurais que nÃ£o possuem remanescentes de vegetaÃ§Ã£o nativa para atender a Ã¡rea mÃ­nima a ser mantida como Reserva Legal, conforme definido pela Lei nÂº 12.651/2012. </p><p>No caso de Ã¡reas em processo de recuperaÃ§Ã£o, a Cota de Reserva Ambiental - CRA nÃ£o poderÃ¡ ser emitida quando a regeneraÃ§Ã£o ou recomposiÃ§Ã£o da Ã¡rea forem improvÃ¡veis ou inviÃ¡veis. </p>"
                }, {
                    id: "69",
                    categoria: "compensacaoReserva",
                    pergunta: "Como podem ser instituÃ­das as Cotas de Reserva Ambiental?",
                    resposta: "<p>As Cotas podem ser instituÃ­das: </p><ul><li>sob regime de servidÃ£o ambiental;</li><li>correspondente Ã  Ã¡rea de Reserva Legal instituÃ­da voluntariamente sobre a vegetaÃ§Ã£o que exceder os percentuais exigidos na Lei 12.651/2012;</li><li>protegida na forma de Reserva Particular do PatrimÃ´nio Natural - RPPN, nos termos do art. 21 da Lei no 9.985, de 18 de julho de 2000;</li><li>existente em propriedade rural localizada no interior de Unidade de ConservaÃ§Ã£o de domÃ­nio pÃºblico que ainda nÃ£o tenha sido desapropriada.</li></ul>"
                }, {
                    id: "70",
                    categoria: "compensacaoReserva",
                    pergunta: "JÃ¡ Ã© possÃ­vel emitir uma Cota de Reserva Ambiental? ",
                    resposta: "NÃ£o, a Cota de Reserva Ambiental - CRA ainda nÃ£o foi regulamentada pelo governo Federal e portanto ainda nÃ£o Ã© possÃ­vel emitir uma Cota de Reserva Ambiental."
                }, {
                    id: "71",
                    categoria: "compensacaoReserva",
                    pergunta: "Qual a diferenÃ§a entre a Cota de Reserva Ambiental e a Cota de Reserva Florestal?",
                    resposta: "<p>A Cota de Reserva Florestal (CRF) foi criada em 2000 e incluÃ­da na Lei nÂº 4.771/1965 como tÃ­tulo representativo de vegetaÃ§Ã£o nativa sob regime de servidÃ£o florestal, de Reserva Particular do PatrimÃ´nio Natural ou Reserva Legal instituÃ­da voluntariamente sobre a vegetaÃ§Ã£o que excedesse os percentuais estabelecidos na legislaÃ§Ã£o vigente Ã  Ã©poca. As possibilidades de emissÃ£o da CRF eram limitadas se comparadas as possibilidades de emissÃ£o da CRA. </p><p>Todavia, as CRF emitida nos termos da lei passam a ser consideradas CRA, mediante validaÃ§Ã£o pelo Ã³rgÃ£o ambiental estadual ou do Distrito Federal e atendimento aos demais requisitos aplicÃ¡veis da Lei nÂº 12.651/12.</p>"
                }, {
                    id: "72",
                    categoria: "compensacaoReserva",
                    pergunta: "O que Ã© o arrendamento de Ã¡rea sob regime de ServidÃ£o Ambiental ou Reserva Legal, para fins de compensaÃ§Ã£o?",
                    resposta: "<p>A ServidÃ£o Ambiental Ã© a restriÃ§Ã£o estabelecida voluntariamente pelo proprietÃ¡rio para limitar a utilizaÃ§Ã£o de Ã¡reas naturais existentes e pode ser onerosa ou gratuita, temporÃ¡ria ou perpÃ©tua. Este mecanismo nÃ£o se aplica Ã s Ãreas de PreservaÃ§Ã£o Permanente e Ã  Reserva Legal mÃ­nima exigida. </p><p>Nessa modalidade de compensaÃ§Ã£o de Reserva Legal, o proprietÃ¡rio/possuidor detentor da ServidÃ£o Ambiental ou Reserva Legal aliena, cede ou transfere a Ã¡rea para aquele que possui o dÃ©ficit a compensar, mediante retribuiÃ§Ã£o ou aluguel, por meio de contrato. </p><p>A instituiÃ§Ã£o e utilizaÃ§Ã£o das Ã¡reas sob regime de servidÃ£o ambiental ou Reserva Legal para fins de compensaÃ§Ã£o de Reserva Legal deverÃ£o ser feitas nos termos dos artigos 78 e 79 da Lei 12.651/12 e deverÃ£o ser aprovadas pelo Ã³rgÃ£o estadual competente, cujo contato pode ser consultado por meio do link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>. Na hipÃ³tese de compensaÃ§Ã£o de Reserva Legal, a servidÃ£o ambiental ou Reserva Legal deve ser averbada na matrÃ­cula de todos os imÃ³veis envolvidos.</p>"
                }, {
                    id: "73",
                    categoria: "compensacaoReserva",
                    pergunta: "O que Ã© a doaÃ§Ã£o ao poder pÃºblico de Ã¡rea localizada no interior de Unidade de ConservaÃ§Ã£o de domÃ­nio pÃºblico pendente de regularizaÃ§Ã£o fundiÃ¡ria, para fins de compensaÃ§Ã£o?",
                    resposta: "<p>As Ã¡reas localizadas em Unidades de ConservaÃ§Ã£o de domÃ­nio pÃºblico, pendentes de regularizaÃ§Ã£o fundiÃ¡ria, poderÃ£o ser adquiridas por detentores de imÃ³veis com dÃ©ficits de Reserva Legal e posteriormente serem doadas ao poder pÃºblico para fins de compensaÃ§Ã£o de RL.</p><p>Esta modalidade de compensaÃ§Ã£o de RL prevÃª que o proprietÃ¡rio deficitÃ¡rio ao realizar a doaÃ§Ã£o ao poder pÃºblico fique desonerado perpetuamente de suas obrigaÃ§Ãµes de recuperar e/ou compensar RL.</p><p>A doaÃ§Ã£o dessas Ã¡reas para fins de compensaÃ§Ã£o de Reserva Legal estÃ¡ sujeita a confirmaÃ§Ã£o e aprovaÃ§Ã£o do Ã³rgÃ£o gestor da Unidade de ConservaÃ§Ã£o, e Ã  aprovaÃ§Ã£o do Ã³rgÃ£o estadual competente, cujo contato pode ser consultado por meio do link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p><p>Nos casos de imÃ³veis localizados no interior de Unidades de ConservaÃ§Ã£o federais, o Ã³rgÃ£o gestor responsÃ¡vel Ã© o Instituto Chico Mendes de ConservaÃ§Ã£o da Biodiversidade â€“ ICMBio, . Este Ã³rgÃ£o jÃ¡ criou uma plataforma com informaÃ§Ãµes sobre os imÃ³veis, localizados no interior de Unidade de ConservaÃ§Ã£o, para os quais foram emitidas CertidÃµes de HabilitaÃ§Ã£o para CompensaÃ§Ã£o de Reserva Legal e tiveram sua divulgaÃ§Ã£o devidamente autorizada. Esta plataforma estÃ¡ disponÃ­vel no  endereÃ§o eletrÃ´nico: <a href='http://www.icmbio.gov.br/portal/compensacaodereservalegal'>http://www.icmbio.gov.br/portal/compensacaodereservalegal</a>.</p>"
                }, {
                    id: "74",
                    categoria: "compensacaoReserva",
                    pergunta: "O que Ã© o cadastramento, para fins de compensaÃ§Ã£o, de outra Ã¡rea equivalente e excedente Ã  Reserva Legal em imÃ³vel de mesma titularidade ou adquirida em imÃ³vel de terceiro, com vegetaÃ§Ã£o nativa, em regeneraÃ§Ã£o ou recomposiÃ§Ã£o?",
                    resposta: "<p>Nesta modalidade, a compensaÃ§Ã£o da Reserva Legal se dÃ¡ por meio do cadastramento, no Ã¢mbito do SICAR, de um excedente de Reserva Legal (ativo florestal) equivalente Ã  Ã¡rea que precisa ser compensada. Nesse caso, os ativos florestais poderÃ£o estar localizados em imÃ³veis rurais pertencentes ao prÃ³prio detentor do imÃ³vel cujo passivo ambiental pretende-se regularizar, ou localizados em imÃ³veis de terceiros, sendo necessÃ¡ria a manifestaÃ§Ã£o do detentor do imÃ³vel confirmando a aquisiÃ§Ã£o da Ã¡rea excedente de Reserva Legal para fins de compensaÃ§Ã£o de Reserva Legal. O cadastramento de Ã¡rea excedente para fins de compensaÃ§Ã£o de Reserva Legal deve ser aprovada pelo Ã³rgÃ£o estadual competente, cujo contato pode ser consultado por meio do link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a></p>"
                }, {
                    id: "75",
                    categoria: "beneficios",
                    pergunta: "Quais sÃ£o os benefÃ­cios de inscrever o imÃ³vel rural no CAR?",
                    resposta: "<p>Os benefÃ­cios de inscrever o imÃ³vel rural no CAR sÃ£o:</p><ul><li>possibilitar o planejamento ambiental e econÃ´mico do uso e ocupaÃ§Ã£o do imÃ³vel rural;</li><li>a obtenÃ§Ã£o da regularidade ambiental do imÃ³vel, caso necessÃ¡ria;</li><li>o acesso a uma sÃ©rie de autorizaÃ§Ãµes e licenÃ§as que envolvem a supressÃ£o de vegetaÃ§Ã£o nativa;</li><li>O registro da Reserva Legal no CAR desobriga a averbaÃ§Ã£o desta no CartÃ³rio de Registro de ImÃ³veis;</li><li>O acesso a crÃ©dito agrÃ­cola, em qualquer de suas modalidades, a partir de 31 dezembro de 2017, terÃ¡ como condiÃ§Ã£o obrigatÃ³ria a comprovaÃ§Ã£o da inscriÃ§Ã£o no CAR;</li><li>A comprovaÃ§Ã£o da inscriÃ§Ã£o no CAR poderÃ¡ auxiliar na obtenÃ§Ã£o de crÃ©dito agrÃ­cola, em todas as suas modalidades, com taxas de juros menores, bem como limites e prazos maiores que o praticado no mercado, em especial apÃ³s 31 de dezembro de 2017, quando serÃ¡ prÃ©-requisito para o acesso a crÃ©dito;</li><li>PoderÃ£o ser contratados seguros agrÃ­colas em condiÃ§Ãµes melhores que as praticadas no mercado;</li><li>GeraÃ§Ã£o de crÃ©ditos tributÃ¡rios por meio da deduÃ§Ã£o das Ãreas de PreservaÃ§Ã£o Permanente, de Reserva Legal e de uso restrito da base de cÃ¡lculo do Imposto sobre a Propriedade Territorial Rural - ITR; e</li><li>IsenÃ§Ã£o de impostos para os principais insumos e equipamentos, tais como: fio de arame, postes de madeira tratada, bombas dâ€™Ã¡gua, trado de perfuraÃ§Ã£o do solo, dentre outros utilizados para os processos de recuperaÃ§Ã£o e manutenÃ§Ã£o das Ãreas de PreservaÃ§Ã£o Permanente, de Reserva Legal e de uso restrito.</li></ul>"
                }, {
                    id: "76",
                    categoria: "beneficios",
                    pergunta: "Quais sÃ£o os benefÃ­cios de inscrever no CAR um imÃ³vel rural que possua excedente de vegetaÃ§Ã£o nativa em relaÃ§Ã£o Ã  Reserva Legal?",
                    resposta: "<p>Os imÃ³veis inscritos no CAR que possuem excedente de vegetaÃ§Ã£o nativa em relaÃ§Ã£o Ã  Reserva Legal mÃ­nima podem destinÃ¡-las para compensaÃ§Ã£o de outros imÃ³veis que estejam devendo Reserva Legal. AlÃ©m disso, podem ter acesso a outros benefÃ­cios como apoio tÃ©cnico e incentivos financeiros criados em Ã¢mbito federal, estadual ou municipal que incluem medidas indutoras e linhas de financiamento para atender, prioritariamente, Ã s pequenas propriedades ou posses rurais familiares, nas iniciativas de:</p><ul><li>PreservaÃ§Ã£o voluntÃ¡ria de vegetaÃ§Ã£o nativa acima dos limites estabelecidos no art. 12 da Lei 12.651/12;</li><li>ProteÃ§Ã£o de espÃ©cies da flora nativa ameaÃ§adas de extinÃ§Ã£o;</li><li>ImplantaÃ§Ã£o de sistemas agroflorestal e agrossilvipastoril;</li><li>ProduÃ§Ã£o de mudas e sementes;</li><li>Pagamento por serviÃ§os ambientais.</li></ul>"
                }, {
                    id: "77",
                    categoria: "beneficios",
                    pergunta: "Quais sÃ£o os benefÃ­cios de inscrever no CAR um imÃ³vel rural que possua necessidade de regularizaÃ§Ã£o ambiental?",
                    resposta: "A inscriÃ§Ã£o no CAR Ã© condiÃ§Ã£o obrigatÃ³ria para a adesÃ£o aos Programas de RegularizaÃ§Ã£o Ambiental (PRA) estaduais e ao aderir ao PRA, e enquanto estiverem sendo cumpridas as obrigaÃ§Ãµes estabelecidas no PRA ou no Termo de Compromisso para a regularizaÃ§Ã£o ambiental, o proprietÃ¡rio-possuidor tem acesso a uma sÃ©rie de benefÃ­cios. "
                }, {
                    id: "78",
                    categoria: "beneficios",
                    pergunta: "Quais sÃ£o as possibilidades de utilizaÃ§Ã£o dos remanescentes de vegetaÃ§Ã£o nativa excedente ao mÃ­nimo exigido para Reserva Legal?",
                    resposta: "<p>O proprietÃ¡rio ou possuidor rural de imÃ³vel com Reserva Legal conservada e inscrita no CAR, cuja Ã¡rea ultrapasse o mÃ­nimo exigido na Lei 12.651/2012, poderÃ¡ utilizar a Ã¡rea excedente de Reserva Legal como um ativo, a ser negociado com os detentores de imÃ³veis rurais que detinham, em 22 de julho de 2008, Ã¡rea de Reserva Legal em extensÃ£o inferior ao estabelecido no art. 12 da Lei 12.651/2012 e optaram por adotar a CompensaÃ§Ã£o de Reserva Legal. </p><p>Para a utilizaÃ§Ã£o destes excedentes de vegetaÃ§Ã£o, os proprietÃ¡rios podem:</p><ul><li>emitir Cota de Reserva Ambiental sobre a vegetaÃ§Ã£o excedente;</li><li>arrendar a Ã¡rea excedente sob regime de servidÃ£o ambiental ou Reserva Legal; e</li><li>permitir o cadastramento de Ã¡rea equivalente ao dÃ©ficit de Reserva Legal em Ã¡rea excedente de vegetaÃ§Ã£o nativa, em regeneraÃ§Ã£o ou recomposiÃ§Ã£o.</li></ul>"
                }, {
                    id: "79",
                    categoria: "benefÃ­cios",
                    pergunta: "Quais os benefÃ­cios de adesÃ£o ao Programa de RegularizaÃ§Ã£o Ambiental - PRA?",
                    resposta: "<p>Ao aderir ao PRA, e enquanto estiverem sendo cumpridas as obrigaÃ§Ãµes estabelecidas no PRA ou no Termo de Compromisso para a regularizaÃ§Ã£o ambiental, o proprietÃ¡rio-possuidor tem acesso aos seguintes benefÃ­cios:</p><ul><li>a suspensÃ£o de sanÃ§Ãµes administrativas decorrentes de autuaÃ§Ãµes por infraÃ§Ãµes cometidas antes de 22 de julho de 2008, relacionadas Ã  supressÃ£o irregular de vegetaÃ§Ã£o em Reserva Legal, caso existam;</li><li>a suspensÃ£o da punibilidade quanto Ã : corte de Ã¡rvore sem permissÃ£o da autoridade competente; destruiÃ§Ã£o ou danificaÃ§Ã£o de floresta, mesmo que em formaÃ§Ã£o, ou utilizÃ¡-la com infringÃªncia das normas de proteÃ§Ã£o; e impedir ou dificultar a regeneraÃ§Ã£o natural de florestas e demais formas de vegetaÃ§Ã£o, desde que efetuadas atÃ© 22 de julho de 2008;</li><li>a manutenÃ§Ã£o de atividades nas Ãreas de PreservaÃ§Ã£o Permanente, uso restrito e de Reserva Legal desmatadas atÃ© 22 de julho de 2008;</li><li>acesso Ã  apoio tÃ©cnico e incentivos financeiros criados em Ã¢mbito federal, estadual ou municipal que poderÃ£o incluir medidas indutoras e linhas de financiamento para atender, prioritariamente, Ã s pequenas propriedades ou posses rurais familiares, nas iniciativas de (i) RecuperaÃ§Ã£o ambiental de Ãreas de PreservaÃ§Ã£o Permanente e de Reserva Legal; (ii) RecuperaÃ§Ã£o de Ã¡reas degradadas; e (iii) PromoÃ§Ã£o de assistÃªncia tÃ©cnica para regularizaÃ§Ã£o ambiental e recuperaÃ§Ã£o de Ã¡reas degradadas.</li></ul><p>Com a efetiva regularizaÃ§Ã£o do imÃ³vel rural, as multas das autuaÃ§Ãµes cometidas serÃ£o consideradas como convertidas em serviÃ§os de preservaÃ§Ã£o, melhoria e recuperaÃ§Ã£o da qualidade do meio ambiente, e serÃ¡ extinta a punibilidade.</p><p>Identificada na inscriÃ§Ã£o a necessidade de recomposiÃ§Ã£o de vegetaÃ§Ã£o nativa, o proprietÃ¡rio ou possuidor de imÃ³vel rural poderÃ¡ solicitar de imediato a adesÃ£o ao Programa de RegularizaÃ§Ã£o Ambiental - PRA, sendo que, com base no requerimento de adesÃ£o ao PRA, o Ã³rgÃ£o estadual competente convocarÃ¡ o proprietÃ¡rio ou possuidor para assinar o termo de compromisso.</p><p>Mais informaÃ§Ãµes sobre o PRA podem ser obtidas junto ao Ã³rgÃ£o estadual competente, cujo contato pode ser consultado por meio do link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "80",
                    categoria: "beneficios",
                    pergunta: "Quais os benefÃ­cios da inscriÃ§Ã£o no CAR para os imÃ³veis rurais de atÃ© 4 (quatro) mÃ³dulos fiscais e de povos e comunidades tradicionais?",
                    resposta: "<p>A Lei 12.651/12 assegurou benefÃ­cios para aqueles imÃ³veis atÃ© 4 mÃ³dulos fiscais e de povos e comunidades tradicionais, entre eles:</p><ul><li>A inscriÃ§Ã£o garante para estes imÃ³veis a possibilidade de intervenÃ§Ã£o e supressÃ£o de vegetaÃ§Ã£o em Ãreas de PreservaÃ§Ã£o Permanente - APP e de Reserva Legal por meio da simples declaraÃ§Ã£o ao Ã³rgÃ£o ambiental competente, para as atividades eventuais ou de baixo impacto ambiental, conceituadas na Lei 12.651/12, excetuadas a implantaÃ§Ã£o de instalaÃ§Ãµes de Ã¡gua e efluentes e a pesquisa cientÃ­fica relativa a recursos ambientais;</li><li>AuxÃ­lio tÃ©cnico e jurÃ­dico do poder pÃºblico estadual para inscriÃ§Ã£o e registro da Reserva Legal no CAR e a recomposiÃ§Ã£o da vegetaÃ§Ã£o nativa;</li><li>A adesÃ£o ao Programa de RegularizaÃ§Ã£o Ambiental - PRA da Lei 12.651/12, tambÃ©m trouxe tratamento diferenciado para os imÃ³veis atÃ© 4 mÃ³dulos fiscais e de povos e comunidades tradicionais, dentre eles:<ul><li>Possibilidade, para aqueles imÃ³veis com atÃ© 4 mÃ³dulos fiscais em 22 de julho de 2008, da Reserva Legal ser constituÃ­da com a Ã¡rea ocupada com a vegetaÃ§Ã£o nativa existente em 22 de julho de 2008, vedadas novas conversÃµes para uso alternativo do solo;</li><li>Possibilidade, para aqueles imÃ³veis com atÃ© 4 mÃ³dulos fiscais em 22 de julho de 2008, de reduÃ§Ã£o da faixa a ser recomposta em Ã¡reas consolidadas em Ãreas de PreservaÃ§Ã£o Permanente â€“ APPs;</li><li>RecomposiÃ§Ã£o de Ã¡rea consolidada em APP por meio do plantio intercalado de espÃ©cies lenhosas, perenes ou de ciclo longo, exÃ³ticas com nativas de ocorrÃªncia regional, em atÃ© 50% (cinquenta por cento) da Ã¡rea total a ser recomposta.</li></ul></li></ul>"
                }, {
                    id: "81",
                    categoria: "benefÃ­cios",
                    pergunta: "Quais as possibilidades de utilizaÃ§Ã£o da vegetaÃ§Ã£o nativa existente ou em recomposiÃ§Ã£o que compÃµe a Reserva Legal?",
                    resposta: "<p>Para a vegetaÃ§Ã£o nativa que compÃµe a Reserva Legal Ã© permitida a sua exploraÃ§Ã£o econÃ´mica mediante manejo sustentÃ¡vel, previamente aprovado pelo Ã³rgÃ£o estadual competente, de acordo com as modalidades de manejo sustentÃ¡vel sem propÃ³sito comercial para consumo na propriedade e manejo sustentÃ¡vel para exploraÃ§Ã£o florestal com propÃ³sito comercial.</p><p>Nas Ã¡reas em recomposiÃ§Ã£o sob regime de Reserva Legal podem ser utilizadas espÃ©cies nativas e exÃ³ticas, em sistema agroflorestal, sendo que o plantio de espÃ©cies exÃ³ticas deverÃ¡ ser combinado com as espÃ©cies nativas de ocorrÃªncia regional e a Ã¡rea recomposta com espÃ©cies exÃ³ticas nÃ£o poderÃ¡ exceder a cinquenta por cento da Ã¡rea total a ser recuperada. O proprietÃ¡rio ou possuidor de imÃ³vel rural que optar por recompor a Reserva Legal com utilizaÃ§Ã£o do plantio intercalado de espÃ©cies exÃ³ticas e nativas terÃ¡ direito a sua exploraÃ§Ã£o econÃ´mica. </p>"
                }, {
                    id: "81",
                    categoria: "dados",
                    pergunta: "Como Ã© possÃ­vel obter informaÃ§Ãµes sobre os dados declarados no CAR em municÃ­pios, estados ou no Brasil?",
                    resposta: "<p>InformaÃ§Ãµes sobre os dados declarados no CAR em municÃ­pios, estados e no Brasil estÃ£o disponÃ­veis para consulta e download no MÃ³dulo de RelatÃ³rios pÃºblico do SICAR, Boletim Informativo do CAR e Atlas do CAR, acessÃ­veis pelo site do ServiÃ§o Florestal Brasileiro â€“ SFB - <a href='http://www.florestal.gov.br/'>http://www.florestal.gov.br/</a> . Podem ser encontradas informaÃ§Ãµes sobre: quantitativo e Ã¡rea de imÃ³veis rurais cadastrados por municÃ­pio, estado ou Brasil; Ã¡rea passÃ­vel de cadastro por estado, regiÃ£o e Brasil; incremento mensal de cadastro por estado, regiÃ£o e Brasil; Remanescentes de VegetaÃ§Ã£o Nativa (RVN), Ãreas de PreservaÃ§Ã£o Permanente (APP), Reserva Legal e Nascentes por estado e Brasil; entre outras. Seguem links para acesso direto:</p><ul><li>MÃ³dulo de RelatÃ³rios pÃºblico do SICAR: <a href='http://www.florestal.gov.br/modulo-de-relatorios'>http://www.florestal.gov.br/modulo-de-relatorios</a></li><li>Boletim Informativo do CAR: <a href='http://www.florestal.gov.br/index.php?option=com_content&view=article&id=77&catid=61&Itemid=264'>http://www.florestal.gov.br/cadastro-ambiental-rural/numeros-do-cadastro-ambiental-rural</a></li><li>Atlas do CAR: <a href='http://www.florestal.gov.br/cadastro-ambiental-rural/atlas-car-dados-por-unidade-da-federacao-maio-de-2016'>http://www.florestal.gov.br/cadastro-ambiental-rural/atlas-car-dados-por-unidade-da-federacao-maio-de-2016</a></li></ul><p>Outras informaÃ§Ãµes podem estar disponÃ­veis junto ao Ã³rgÃ£o estadual de meio ambiente competente. Os contatos, por estado, podem ser consultados por meio do link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "82",
                    categoria: "dados",
                    pergunta: "Como Ã© possÃ­vel obter informaÃ§Ãµes referentes Ã  Ã¡rea cadastrÃ¡vel no CAR em um estado ou no Brasil?",
                    resposta: "<p>InformaÃ§Ãµes sobre Ã¡rea cadastrÃ¡vel em estados e no Brasil estÃ£o disponÃ­veis para consulta e download no Boletim Informativo do CAR, acessados pelo site do ServiÃ§o Florestal Brasileiro â€“ SFB <a href='http://www.florestal.gov.br/index.php?option=com_content&view=article&id=77&catid=61&Itemid=264'>http://www.florestal.gov.br/cadastro-ambiental-rural/numeros-do-cadastro-ambiental-rural</a>.</p><p>Outras informaÃ§Ãµes podem estar disponÃ­veis junto ao Ã³rgÃ£o estadual de meio ambiente competente. Os contatos, por estado, podem ser consultados por meio do link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "83",
                    categoria: "dados",
                    pergunta: "Como Ã© possÃ­vel obter informaÃ§Ãµes sobre os dados declarados no CAR referentes a nÃºmero e Ã¡rea de imÃ³veis rurais em um municÃ­pio, estado ou Brasil?",
                    resposta: "<p>InformaÃ§Ãµes sobre os dados declarados no CAR referentes Ã  nÃºmero e Ã¡rea de imÃ³veis rurais estÃ£o disponÃ­veis para consulta e download no MÃ³dulo de RelatÃ³rios pÃºblico do SICAR e no Boletim Informativo do CAR, acessados pelo site do ServiÃ§o Florestal Brasileiro â€“ SFB - <a href='http://www.florestal.gov.br/'>http://www.florestal.gov.br/</a> . Seguem links para acesso direto:</p><ul><li>â€œMÃ³dulo de RelatÃ³riosâ€: <a href='http://www.florestal.gov.br/modulo-de-relatorios'>http://www.florestal.gov.br/modulo-de-relatorios</a></li><li>â€œNÃºmeros do CARâ€: <a href='http://www.florestal.gov.br/index.php?option=com_content&view=article&id=77&catid=61&Itemid=264'>http://www.florestal.gov.br/cadastro-ambiental-rural/numeros-do-cadastro-ambiental-rural</a></li></ul><p>Outras informaÃ§Ãµes podem estar disponÃ­veis junto ao Ã³rgÃ£o estadual de meio ambiente competente. Os contatos, por estado, podem ser consultados por meio do link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "84",
                    categoria: "dados",
                    pergunta: "Como Ã© possÃ­vel obter informaÃ§Ãµes sobre os dados declarados no CAR referentes a Remanescentes de VegetaÃ§Ã£o Nativa, Ãreas de PreservaÃ§Ã£o Permanente, Reserva Legal e Nascentes?",
                    resposta: "<p>InformaÃ§Ãµes sobre os dados declarados no CAR referentes Ã  Remanescentes de VegetaÃ§Ã£o Nativa, Ãreas de PreservaÃ§Ã£o Permanente, Reserva Legal  e Nascentes estÃ£o disponÃ­veis para consulta e download em:</p><ul><li>Boletim Informativo - 2 anos - Abril 2016 - dados Brasil <a href='http://www.florestal.gov.br/index.php?option=com_content&view=article&id=77&catid=61&Itemid=264'>(http://www.florestal.gov.br/cadastro-ambiental-rural/numeros-do-cadastro-ambiental-rural)</a>;</li><li>Boletim Informativo - 2 anos - Abril 2016 - dados Estados <a href='http://www.florestal.gov.br/index.php?option=com_content&view=article&id=77&catid=61&Itemid=264'>(http://www.florestal.gov.br/cadastro-ambiental-rural/numeros-do-cadastro-ambiental-rural)</a>; e</li><li>Atlas do CAR, <a href='http://www.florestal.gov.br/cadastro-ambiental-rural/atlas-car-dados-por-unidade-da-federacao-maio-de-2016'>http://www.florestal.gov.br/cadastro-ambiental-rural/atlas-car-dados-por-unidade-da-federacao-maio-de-2016</a>.</li></ul><p>Outras informaÃ§Ãµes podem estar disponÃ­veis junto ao Ã³rgÃ£o estadual de meio ambiente competente. Os contatos, por estado, podem ser consultados por meio do link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "85",
                    categoria: "dados",
                    pergunta: "O que Ã© o MÃ³dulo de RelatÃ³rios pÃºblico do SICAR?",
                    resposta: "<p>O MÃ³dulo de RelatÃ³rios Ã© um ambiente pÃºblico de consulta de informaÃ§Ãµes sobre dados declarados de desde o inÃ­cio da implantaÃ§Ã£o do CAR, em 06 maio de 2014, atÃ© o Ãºltimo dia do mÃªs anterior ao corrente, relativas Ã : quantitativo e Ã¡rea de imÃ³veis rurais cadastrados em valores absolutos e percentuais, por municÃ­pio, estado ou Brasil, em nÃºmeros totais, ou classificados por tipo de imÃ³vel (rural; povos e comunidades tradicionais; assentamentos de reforma agrÃ¡ria) e perfil de imÃ³vel (atÃ© 4 mÃ³dulos fiscais, de 4 a 15 mÃ³dulos fiscais, maior que 15 mÃ³dulos fiscais). Ã‰ possÃ­vel fazer o download de planilha eletrÃ´nica com os resultados da consulta realizada. O MÃ³dulo de RelatÃ³rios pode ser acessado por meio do site do ServiÃ§o Florestal Brasileiro, diretamente pelo link <a href='http://www.florestal.gov.br/modulo-de-relatorios'>http://www.florestal.gov.br/modulo-de-relatorios</a>.</p>"
                }, {
                    id: "86",
                    categoria: "dados",
                    pergunta: "O que Ã© o Boletim Informativo do CAR?",
                    resposta: "<p>O Boletim Informativo do CAR Ã© uma publicaÃ§Ã£o mensal do ServiÃ§o Florestal Brasileiro â€“ SFB, iniciada em julho de 2016, que contÃ©m informaÃ§Ãµes sobre dados declarados no CAR atÃ© o Ãºltimo dia do mÃªs anterior ao mÃªs corrente, relativos Ã : nÃºmero de imÃ³veis cadastrados, Ã¡rea passÃ­vel de cadastro, Ã¡rea total cadastrada (valores absolutos e percentuais) e incremento mensal, por estado, regiÃ£o e Brasil. </p><p>O boletim conta com ediÃ§Ãµes especiais: â€œBoletim Informativo - EdiÃ§Ã£o Extra - Extrato Brasil - dados atÃ© 5 de maio de 2016â€, â€œBoletim Informativo - 2 anos - Abril 2016 - dados Brasilâ€ e â€œBoletim Informativo - 2 anos - Abril 2016 - dados Estadosâ€. Nessas ediÃ§Ãµes, alÃ©m dos dados e informaÃ§Ãµes jÃ¡ citados, podem ser encontrados nÃºmeros referentes Ã :</p><ol><li>AdesÃ£o ao PRA, </li><li>Alternativas de regularizaÃ§Ã£o da Reserva Legal, </li><li>SituaÃ§Ã£o da implantaÃ§Ã£o do SICAR nos estados,</li><li>PÃºblico usuÃ¡rio do SICAR,</li><li>Recursos investidos,</li><li>CapacitaÃ§Ã£o e formaÃ§Ã£o de tÃ©cnicos para o cadastramento, </li><li>CAR na bacia do rio SÃ£o Francisco, </li><li>CAR na bacia do rio Doce, </li><li>DistribuiÃ§Ã£o dos cadastros por Bioma, </li><li>CAR nos municÃ­pios prioritÃ¡rios para monitoramento na AmazÃ´nia Legal, </li><li>CAR na AmazÃ´nia Legal, </li><li>Projetos Internacionais e Editais do MMA para apoio ao CAR/PRA, </li><li>Ãrea de atuaÃ§Ã£o dos projetos do ServiÃ§o Florestal Brasileiro para fomento Ã  regularizaÃ§Ã£o ambiental de imÃ³veis rurais, </li><li>LocalizaÃ§Ã£o dos centros de desenvolvimento florestal no Brasil, </li><li>RecuperaÃ§Ã£o de APP em bacias que abastecem regiÃµes metropolitanas com alta criticidade hÃ­drica, </li><li>Arquitetura do SICAR,</li><li>Marcos Legais.</li></ol><p>Todas as ediÃ§Ãµes estÃ£o disponÃ­veis para consulta e download no site do ServiÃ§o Florestal Brasileiro, diretamente pelo link <a href='http://www.florestal.gov.br/index.php?option=com_content&view=article&id=77&catid=61&Itemid=264'>http://www.florestal.gov.br/cadastro-ambiental-rural/numeros-do-cadastro-ambiental-rural</a>.</p>"
                }, {
                    id: "87",
                    categoria: "dados",
                    pergunta: "O que Ã© o Atlas do CAR?",
                    resposta: "<p>O Atlas do CAR Ã© uma coleÃ§Ã£o de mapas contendo informaÃ§Ãµes ambientais sobre dados declarados no CAR atÃ© maio de 2016, publicado pelo SFB/MMA junto ao â€œBoletim Informativo do CAR â€“ EdiÃ§Ã£o Extra â€“ Extrato Brasilâ€. Ã‰ possÃ­vel fazer o download dos mapas, por estado e Brasil, relativos Ã : </p><ul><li>Ãreas cadastradas, </li><li>Remanescentes de VegetaÃ§Ã£o Nativa (RVN), </li><li>Ãreas de PreservaÃ§Ã£o Permanente (APP), </li><li>Reserva Legal (RL) e </li><li>Nascentes </li></ul><p>Estas informaÃ§Ãµes estÃ£o disponÃ­veis no site do ServiÃ§o Florestal Brasileiro, diretamente pelo link <a href='http://www.florestal.gov.br/cadastro-ambiental-rural/atlas-car-dados-por-unidade-da-federacao-maio-de-2016'>http://www.florestal.gov.br/cadastro-ambiental-rural/atlas-car-dados-por-unidade-da-federacao-maio-de-2016</a>.</p>"
                }, {
                    id: "88",
                    categoria: "dados",
                    pergunta: "Qual Ã© a diferenÃ§a entre as informaÃ§Ãµes contidas no Boletim Informativo do CAR e no MÃ³dulo de RelatÃ³rios pÃºblico do SICAR?",
                    resposta: "<p>As informaÃ§Ãµes disponibilizadas no MÃ³dulo de RelatÃ³rios pÃºblico do SICAR sÃ£o geradas por meio do processamento automatizado e simplificado dos dados constantes na base do SICAR. JÃ¡ as informaÃ§Ãµes dos Boletins provÃªm de metodologia diferenciada incluindo, por exemplo, dados em fase de integraÃ§Ã£o com o SICAR. Essa diferenÃ§a metodolÃ³gica pode levar a divergÃªncias em funÃ§Ã£o de:</p><ul><li>metodologia de elaboraÃ§Ã£o do Boletim, que, no caso nÃºmero de imÃ³veis declarados no CAR, considera o nÃºmero de famÃ­lias registradas nos imÃ³veis rurais de assentamentos da reforma agrÃ¡ria, ao passo que o MÃ³dulo PÃºblico de RelatÃ³rios apresenta o nÃºmero de assentamentos inscritos no CAR; </li><li>aÃ§Ãµes de monitoramento da base de dados do SICAR, que exclui cadastros evidentemente falsos da contabilizaÃ§Ã£o do Boletim; </li><li>informaÃ§Ãµes declaradas pelos estados que possuem sistemas prÃ³prios de cadastramento cujos dados ainda nÃ£o foram migrados ou estÃ£o em migraÃ§Ã£o ao SICAR; e</li><li>horÃ¡rios divergentes de fechamento das consultas realizadas.</li></ul>"
                }, {
                    id: "89",
                    categoria: "atendimento",
                    pergunta: "Onde tirar dÃºvidas sobre a inscriÃ§Ã£o de um imÃ³vel rural no CAR?",
                    resposta: "<p>A inscriÃ§Ã£o do imÃ³vel rural no CAR deverÃ¡ ser feita junto ao Ã³rgÃ£o estadual competente. InformaÃ§Ãµes bÃ¡sicas sobre a inscriÃ§Ã£o de um imÃ³vel rural no CAR podem ser encontradas nas seÃ§Ãµes â€œSobreâ€ e â€œPerguntas Frequentesâ€, disponÃ­veis na pÃ¡gina do SICAR (www.car.gov.br). Considerando a existÃªncia de especificidades na legislaÃ§Ã£o e em normas de cada unidade da federaÃ§Ã£o Ã© importante buscar maiores esclarecimentos junto aos Ã³rgÃ£os gestores do CAR nos estados, que podem ser consultados por meio link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a> </p>"
                }, {
                    id: "90",
                    categoria: "atendimento",
                    pergunta: "O proprietÃ¡rio/possuidor de imÃ³vel rural com atÃ© 4 mÃ³dulos fiscais pode contar com que tipo de ajudar para inscriÃ§Ã£o do imÃ³vel rural no CAR?",
                    resposta: "<p>A inscriÃ§Ã£o do imÃ³vel rural no CAR deverÃ¡ ser feita junto ao Ã³rgÃ£o estadual competente.  A lei 12.651/12 estipula que o poder pÃºblico deverÃ¡ prestar apoio tÃ©cnico e jurÃ­dico, assegurada a gratuidade, na inscriÃ§Ã£o de imÃ³veis de atÃ© 4 (quatro) mÃ³dulos fiscais e que desenvolva atividades agrossilvipastoris. Mais informaÃ§Ãµes sobre os programas de apoio Ã  inscriÃ§Ã£o no CAR podem estar disponÃ­veis junto aos Ã³rgÃ£os estaduais competentes, que podem ser consultados por meio link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>. </p>"
                }, {
                    id: "91",
                    categoria: "atendimento",
                    pergunta: "Povos/comunidades tradicionais podem contar com que tipo de ajudar para inscriÃ§Ã£o do imÃ³vel rural no CAR?",
                    resposta: "<p>InformaÃ§Ãµes bÃ¡sicas sobre inscriÃ§Ã£o de territÃ³rios de povos e comunidades tradicionais no CAR podem ser encontradas nas seÃ§Ãµes â€œSobreâ€ e â€œPerguntas Frequentesâ€, disponÃ­veis na pÃ¡gina do SICAR (www.car.gov.br).  Mais informaÃ§Ãµes podem estar disponÃ­veis junto os Ã³rgÃ£os estaduais competentes do CAR, conforme contatos disponibilizados no link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>, ou nos seguintes Ã³rgÃ£os: </p><ul><li>CoordenaÃ§Ã£o Nacional de ArticulaÃ§Ã£o das Comunidades Negras Rurais Quilombolas â€“ CONAQ; (61) 8546-2438/ (61) 9511-8374; conaq.campanhaquilombola@gmail.com; <a href='http://quilombosconaq.blogspot.com.br/'>http://quilombosconaq.blogspot.com.br/</a></li><li>FundaÃ§Ã£o Cultural Palmares - Setor Comercial Sul â€“ SCS, Quadra 02, Bloco C, nÂº 256 â€“ EdifÃ­cio Toufic, CEP 70.302-000 â€“ BrasÃ­lia â€“ DF; (61) 3424-0175 / 3424-0139; <a href='www.palmares.gov.br/'>www.palmares.gov.br/</a>;</li><li>FundaÃ§Ã£o Nacional do Ãndio â€“ FUNAI - SBS Quadra 02 Lote 14 Ed. Cleto Meireles 70070-120 - BrasÃ­lia/DF; (61) 3247-6000; <a href='www.funai.gov.br/'>www.funai.gov.br/</a><li></ul>"
                }, {
                    id: "92",
                    categoria: "atendimento",
                    pergunta: "Assentados de reforma agrÃ¡ria podem contar com que tipo de ajudar para inscriÃ§Ã£o do imÃ³vel rural no CAR?",
                    resposta: "<p>InformaÃ§Ãµes bÃ¡sicas sobre inscriÃ§Ã£o de assentamentos de reforma agrÃ¡ria no CAR podem ser encontradas na seÃ§Ã£o â€œSobreâ€ e â€œPerguntas Frequentesâ€, disponÃ­veis na pÃ¡gina do SICAR (www.car.gov.br). Para mais informaÃ§Ãµes, procure os Ã³rgÃ£os gestores do CAR nos estados, conforme contatos disponibilizados no link http://car.gov.br/#/contatos ou o Ã³rgÃ£o fundiÃ¡rio responsÃ¡vel. </p><p>Para os casos de assentamentos federais o responsÃ¡vel Ã© o Instituto Nacional de Reforma AgrÃ¡ria â€“ INCRA, nesses casos mais informaÃ§Ãµes podem ser obtidas em nas representaÃ§Ãµes em cada estado em <a href='http://www.incra.gov.br/incra-nos-estados'>http://www.incra.gov.br/incra-nos-estados</a> ou por meio da Diretoria de ObtenÃ§Ã£o de Terras e ImplantaÃ§Ã£o de Projetos de Assentamento, Telefone: (61) 3411-7125 /7588/7660.</p>"
                }, {
                    id: "93",
                    categoria: "atendimento",
                    pergunta: "Onde tirar dÃºvidas sobre os critÃ©rios de anÃ¡lise e aprovaÃ§Ã£o da Reserva Legal de um cadastro do CAR?",
                    resposta: "<p>Os Ã³rgÃ£os estaduais competentes, ou instituiÃ§Ã£o por eles habilitada, sÃ£o os responsÃ¡veis pela anÃ¡lise dos cadastros e aprovaÃ§Ã£o da localizaÃ§Ã£o da Reserva Legal, apÃ³s a inclusÃ£o do imÃ³vel no CAR. Considerando a existÃªncia de especificidades na legislaÃ§Ã£o e em normas de cada unidade da federaÃ§Ã£o Ã© importante buscar maiores esclarecimentos junto aos Ã³rgÃ£os gestores do CAR nos estados, que podem ser consultados por meio link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                }, {
                    id: "94",
                    categoria: "atendimento",
                    pergunta: "Onde tirar dÃºvidas sobre a situaÃ§Ã£o da regularizaÃ§Ã£o ambiental de um cadastro do CAR?",
                    resposta: "<p>O Demonstrativo da SituaÃ§Ã£o do CAR Ã© disponibilizado pelo SICAR para consultas no prÃ³prio site, link http://www.car.gov.br/#/consultar, ou pela Central do ProprietÃ¡rio / Possuidor, link http://www.car.gov.br/#/central/acesso. Apresenta informaÃ§Ãµes do cadastro quanto Ã  situaÃ§Ã£o (ativo, pendente ou cancelado); Ã  condiÃ§Ã£o (aguardando anÃ¡lise, em anÃ¡lise, analisado com pendÃªncias etc.); e Ã  situaÃ§Ã£o da Reserva Legal (nÃ£o analisada, aprovada e nÃ£o aprovada).</p><p>A anÃ¡lise dos dados declarados no CAR e a aprovaÃ§Ã£o do cadastro sÃ£o de responsabilidade do Ã³rgÃ£o estadual, distrital ou municipal competente, ou de instituiÃ§Ã£o por eles habilitadas. A situaÃ§Ã£o de regularizaÃ§Ã£o ambiental de um imÃ³vel rural decorre da anÃ¡lise e, considerando a existÃªncia de especificidades na legislaÃ§Ã£o e em normas de cada unidade da federaÃ§Ã£o, Ã© importante buscar maiores esclarecimentos junto aos Ã³rgÃ£os gestores do CAR nos Estados, que podem ser consultados por meio link <a href='http://car.gov.br/#/contatos'>http://car.gov.br/#/contatos</a>.</p>"
                } ]
            };
            $scope.init = function() {
                var perguntaAtual = $location.search().pergunta;
                if (perguntaAtual && !isNaN(perguntaAtual)) {
                    $scope.pergunta.selecionada = $scope.faq.perguntas[perguntaAtual];
                    $scope.page.current = $scope.pergunta.selecionada.categoria;
                    $scope.isOpen[perguntaAtual] = true;
                }
                var subPagina = $location.search().subPagina;
                if (subPagina) {
                    $scope.setPage(subPagina);
                }
            };
            $scope.abrirVersaoImpressao = function() {
                window.print();
            };
            $scope.gotoAnchor = function(x) {
                var newHash = "anchor" + x;
                if ($location.hash() !== newHash) {
                    $location.hash("anchor" + x);
                } else {
                    $anchorScroll();
                }
            };
            $scope.setPage = function(pageName, $event) {
                $scope.page.current = pageName;
                if (firstOpenPages.indexOf(pageName) == -1) {
                    $scope.firstPanel.open = false;
                    if ($event && $event.stopPropagation && $event.preventDefault) {
                        $event.stopPropagation();
                        $event.preventDefault();
                    }
                } else {
                    $scope.firstPanel.open = true;
                }
                $scope.limpaPesquisa();
            };
            $scope.limpaPesquisa = function() {
                if ($scope.pergunta.selecionada) {
                    $scope.pergunta.selecionada = null;
                }
            };
            $scope.pageLabelConfig = function(page) {
                return $scope.stateLabels[page - 1];
            };
            $scope.validaPergunta = function() {
                var pergunta = $scope.pergunta.selecionada;
                if (pergunta) {
                    if (pergunta.categoria == "inscricaoCar" || pergunta.categoria == "retificacaoCar" || pergunta.categoria == "regularizacao" || pergunta.categoria == "compensacaoReserva" || pergunta.categoria == "beneficios" || pergunta.categoria == "dados" || pergunta.categoria == "atendimento") {
                        $scope.page.current = pergunta.categoria;
                        return true;
                    }
                    $scope.init = function() {
                        var perguntaAtual = $location.search().pergunta;
                        if (perguntaAtual && !isNaN(perguntaAtual)) {
                            $scope.pergunta.selecionada = $scope.faq.perguntas[perguntaAtual];
                            $scope.page.current = $scope.pergunta.selecionada.categoria;
                            $scope.isOpen[paginaAtual.id] = true;
                        }
                    };
                }
                return false;
            };
            $scope.setIsOpen = function(pergunta, $event) {
                $scope.isOpen[pergunta.id] = true;
            };
            $scope.copiarLink = function(pergunta) {
                if (pergunta) {
                    var link = config.BASE_URL + "#/suporte?pergunta=" + pergunta.id;
                    clipboard.copyText(link);
                    var elemento = $(event.currentTarget);
                    elemento.unbind("mouseleave").tooltip("hide").attr("data-original-title", "Link copiado para a Ã¡rea de transferÃªncia.").tooltip("fixTitle").tooltip("show");
                    setTimeout(function() {
                        elemento.tooltip("destroy");
                    }, 3e3);
                }
            };
            function removeAcentos(palavra) {
                var comAcento = "Ã¡Ã Ã£Ã¢Ã¤Ã©Ã¨ÃªÃ«Ã­Ã¬Ã®Ã¯Ã³Ã²ÃµÃ´Ã¶ÃºÃ¹Ã»Ã¼Ã§ÃÃ€ÃƒÃ‚Ã„Ã‰ÃˆÃŠÃ‹ÃÃŒÃŽÃÃ“Ã’Ã•Ã–Ã”ÃšÃ™Ã›ÃœÃ‡";
                var semAcento = "aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC";
                var nova = "";
                for (var i = 0; i < palavra.length; i++) {
                    if (comAcento.search(palavra.substr(i, 1).replace("(", "\\(").replace(")", "\\)")) >= 0) {
                        nova += semAcento.substr(comAcento.search(palavra.substr(i, 1)), 1);
                    } else {
                        nova += palavra.substr(i, 1);
                    }
                }
                return nova;
            }
            $scope.limpaPesquisaLegislacao = function() {
                $scope.query = {
                    nome: "",
                    descricao: ""
                };
            };
            $scope.customComparator = function(input, actual) {
                var s = removeAcentos(input).toLocaleLowerCase();
                if (s.search(removeAcentos(actual.toLocaleLowerCase())) === -1) return false;
                return true;
            };
            $scope.query = {
                nome: "",
                descricao: ""
            };
            $scope.documentos = [ {
                nome: "RESOLUÃ‡ÃƒO NÂº 4.529, DE 27 DE OUTUBRO DE 2016",
                descricao: "Ajusta as normas do crÃ©dito rural, a fim de adaptÃ¡-las ao teor da Lei nÂº 13.295, de 14 de junho de 2016, e modifica condiÃ§Ãµes relacionadas ao Programa Nacional de Fortalecimento da Agricultura Familiar (Pronaf), ao Programa Nacional de Apoio ao MÃ©dio Produtor Rural (Pronamp) e ao Programa de CapitalizaÃ§Ã£o das Cooperativas de ProduÃ§Ã£o AgropecuÃ¡ria (Procap-Agro).",
                linkSite: "",
                nomeArquivo: "leis/RESOLUCAO4529.pdf"
            }, {
                nome: "LEI NÂº 13.335, DE 14 DE SETEMBRO DE 2016",
                descricao: "Altera a Lei no 12.651, de 25 de maio de 2012, para dispor sobre a extensÃ£o dos prazos de inscriÃ§Ã£o no Cadastro Ambiental Rural e adesÃ£o ao Programa de RegularizaÃ§Ã£o Ambiental.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_Ato2015-2018/2016/Lei/L13335.htm",
                nomeArquivo: ""
            }, {
                nome: "LEI NÂº 13.295, DE 14 DE JUNHO DE 2016",
                descricao: "Novo prazo do CAR. Altera a Lei no 12.096, de 24 de novembro de 2009, a Lei no 12.844, de 19 de julho de 2013, a Lei no 12.651, de 25 de maio de 2012, e a Lei no 10.177, de 12 de janeiro de 2001.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_Ato2015-2018/2016/Lei/L13295.htm",
                nomeArquivo: ""
            }, {
                nome: "MEDIDA PROVISÃ“RIA NÂº 724, DE 4 DE MAIO DE 2016",
                descricao: "Convertida na Lei nÂº 13.335, de 2016",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_Ato2015-2018/2016/Mpv/mpv724.htm",
                nomeArquivo: ""
            }, {
                nome: "INSTRUÃ‡ÃƒO NORMATIVA NÂº 3, DE 18 DE DEZEMBRO DE 2014",
                descricao: "",
                linkSite: "",
                nomeArquivo: "leis/IN_CAR_3.pdf"
            }, {
                nome: "INSTRUÃ‡ÃƒO NORMATIVA NÂº 2, DE 5 DE MAIO DE 2014",
                descricao: "DispÃµe sobre os procedimentos para a integraÃ§Ã£o, execuÃ§Ã£o e compatibilizaÃ§Ã£o do Sistema de Cadastro Ambiental Rural-SICAR e define os procedimentos gerais do Cadastro Ambiental Rural CAR.",
                linkSite: "",
                nomeArquivo: "leis/IN_CAR.pdf"
            }, {
                nome: "DECRETO NÂº 8.235, DE 5 DE MAIO DE 2014",
                descricao: "Estabelece normas gerais complementares aos Programas de RegularizaÃ§Ã£o Ambiental dos Estados e do Distrito Federal, de que trata o Decreto nÂ° 7.830, de 17 de outubro de 2012, institui o Programa Mais Ambiente Brasil, e dÃ¡ outras providÃªncias.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_Ato2011-2014/2014/Decreto/D8235.htm",
                nomeArquivo: "leis/DECRETO8235.pdf"
            }, {
                nome: "LEI NÂº 12.727, DE 17 DE OUTUBRO DE 2012",
                descricao: "Destaque para prazo de 5 anos para crÃ©dito agrÃ­cola. Altera a Lei no 12.651, de 25 de maio de 2012, que dispÃµe sobre a proteÃ§Ã£o da vegetaÃ§Ã£o nativa; altera as Leis nos 6.938, de 31 de agosto de 1981, 9.393, de 19 de dezembro de 1996, e 11.428, de 22 de dezembro de 2006; e revoga as Leis nos 4.771, de 15 de setembro de 1965, e 7.754, de 14 de abril de 1989, a Medida ProvisÃ³ria no 2.166-67, de 24 de agosto de 2001, o item 22 do inciso II do art. 167 da Lei no 6.015, de 31 de dezembro de 1973, e o Â§ 2o do art. 4o da Lei no 12.651, de 25 de maio de 2012.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_ato2011-2014/2012/lei/L12727.htm",
                nomeArquivo: ""
            }, {
                nome: "DECRETO NÂº 7.830, DE 17 DE OUTUBRO DE 2012",
                descricao: "DispÃµe sobre o Sistema de Cadastro Ambiental Rural, o Cadastro Ambiental Rural, estabelece normas de carÃ¡ter geral aos Programas de RegularizaÃ§Ã£o Ambiental, de que trata a Lei no 12.651, de 25 de maio de 2012, e dÃ¡ outras providÃªncias.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_Ato2011-2014/2012/Decreto/D7830.htm",
                nomeArquivo: "leis/DECRETO7830.pdf"
            }, {
                nome: "LEI NÂº 12.651, DE 25 DE MAIO DE 2012",
                descricao: "DispÃµe sobre a proteÃ§Ã£o da vegetaÃ§Ã£o nativa; altera as Leis nos 6.938, de 31 de agosto de 1981, 9.393, de 19 de dezembro de 1996, e 11.428, de 22 de dezembro de 2006; revoga as Leis nos 4.771, de 15 de setembro de 1965, e 7.754, de 14 de abril de 1989, e a Medida ProvisÃ³ria no2.166-67, de 24 de agosto de 2001; e dÃ¡ outras providÃªncias.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_ato2011-2014/2012/lei/l12651.htm",
                nomeArquivo: "leis/LEI12651.pdf"
            }, {
                nome: "DECRETO NÂº 6.514, DE 22 DE JULHO DE 2008",
                descricao: "DispÃµe sobre as infraÃ§Ãµes e sanÃ§Ãµes administrativas ao meio ambiente, estabelece o processo administrativo federal para apuraÃ§Ã£o destas infraÃ§Ãµes, e dÃ¡ outras providÃªncias.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_ato2007-2010/2008/decreto/d6514.htm",
                nomeArquivo: "leis/DECRETO6514.pdf"
            }, {
                nome: "LEI NÂº 11.428, DE 22 DE DEZEMBRO DE 2006",
                descricao: "DispÃµe sobre a utilizaÃ§Ã£o e proteÃ§Ã£o da vegetaÃ§Ã£o nativa do Bioma Mata AtlÃ¢ntica, e dÃ¡ outras providÃªncias.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_ato2004-2006/2006/lei/l11428.htm",
                nomeArquivo: "leis/LEI11428.pdf"
            }, {
                nome: "LEI NÂº 11.284, DE 2 DE MARÃ‡O DE 2006",
                descricao: "DispÃµe sobre a gestÃ£o de florestas pÃºblicas para a produÃ§Ã£o sustentÃ¡vel; institui, na estrutura do MinistÃ©rio do Meio Ambiente, o ServiÃ§o Florestal Brasileiro - SFB; cria o Fundo Nacional de Desenvolvimento Florestal - FNDF; altera as Leis nos 10.683, de 28 de maio de 2003, 5.868, de 12 de dezembro de 1972, 9.605, de 12 de fevereiro de 1998, 4.771, de 15 de setembro de 1965, 6.938, de 31 de agosto de 1981, e 6.015, de 31 de dezembro de 1973; e dÃ¡ outras providÃªncias.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/_ato2004-2006/2006/lei/l11284.htm",
                nomeArquivo: "leis/LEI11283.pdf"
            }, {
                nome: "LEI NÂº 10.650, DE 16 DE ABRIL DE 2003",
                descricao: "DispÃµe sobre o acesso pÃºblico aos dados e informaÃ§Ãµes existentes nos Ã³rgÃ£os e entidades integrantes do Sisnama.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/Leis/2003/L10.650.htm",
                nomeArquivo: "leis/LEI10650.pdf"
            }, {
                nome: "MEDIDA PROVISÃ“RIA NÂº 2.166-67, DE 24 AGOSTO DE 2001",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/mpv/2166-67.htm",
                nomeArquivo: "leis/MP2166-67.pdf"
            }, {
                nome: "MEDIDA PROVISÃ“RIA NÂº 2.166-65, DE 28 JUNHO DE 2001",
                descricao: "",
                linkSite: "https://www.planalto.gov.br/ccivil_03/mpv/2166-65.htm",
                nomeArquivo: "leis/MP2166-65.pdf"
            }, {
                nome: "MEDIDA PROVISÃ“RIA NÂº 2.080-58, DE 27 DEZEMBRO DE 2000",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/2080-58.htm",
                nomeArquivo: "leis/MP2080-58.pdf"
            }, {
                nome: "LEI NÂº 9.985, DE 18 DE JULHO DE 2000",
                descricao: "Regulamenta o art. 225, Â§ 1Â°, incisos I, II, III e VII da ConstituiÃ§Ã£o Federal, institui o Sistema Nacional de Unidades de ConservaÃ§Ã£o da Natureza e dÃ¡ outras providÃªncias.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/2080-58.htm",
                nomeArquivo: "leis/LEI9835.pdf"
            }, {
                nome: "MEDIDA PROVISÃ“RIA NÂº 1.956-44, DE 9 DEZEMBRO DE 1999",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1956-44.htm",
                nomeArquivo: "leis/MP1956-44.pdf"
            }, {
                nome: "MEDIDA PROVISÃ“RIA NÂº 1.885-38, DE 29 JUNHO DE 1999",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1736-32.htm",
                nomeArquivo: "leis/MP1885-38.pdf"
            }, {
                nome: "MEDIDA PROVISÃ“RIA NÂº 1.736-32, DE 13 DE JANEIRO DE 1999",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1736-32.htm",
                nomeArquivo: "leis/MP1736-32.pdf"
            }, {
                nome: "MEDIDA PROVISÃ“RIA NÂº 1.736-31, DE 14 DEZEMBRO DE 1998",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1736-31.htm",
                nomeArquivo: "leis/MP1736-31.pdf"
            }, {
                nome: "MEDIDA PROVISÃ“RIA MEDIDA PROVISÃ“RIA NÂº 1.605-18, de DEZEMBRO DE 1997",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1605-18.htm",
                nomeArquivo: "leis/MP1605-18.pdf"
            }, {
                nome: "MEDIDA PROVISÃ“RIA MEDIDA PROVISÃ“RIA NÂº 1.511-1, DE 22 AGOSTO  DE 1996",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/mpv/Antigas/1511-1.htm",
                nomeArquivo: "leis/MP1511-1.pdf"
            }, {
                nome: "DECRETO NÂº 1.298, DE 27 DE OUTUBRO DE 1994",
                descricao: "Aprova o Regulamento das Florestas Nacionais, e dÃ¡ outras providÃªncias",
                linkSite: "http://www.planalto.gov.br/ccivil_03/decreto/1990-1994/D1298.htm",
                nomeArquivo: "leis/DECRETO1298.pdf"
            }, {
                nome: "DECRETO NÂº 1.282, DE 19 DE OUTUBRO DE 1994",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/decreto/1990-1994/D1282.htm",
                nomeArquivo: "leis/DECRETO1282.pdf"
            }, {
                nome: "LEI NÂº 7.875, DE 13 DE NOVEMBRO DE 1989",
                descricao: "Modifica dispositivo do CÃ³digo Florestal vigente (Lei nÂº 4.771, de 15 de setembro de 1965) para dar destinaÃ§Ã£o especÃ­fica a parte da receita obtida com a cobranÃ§a de ingressos aos visitantes de parques nacionais.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/leis/1989_1994/L7875.htm",
                nomeArquivo: "leis/LEI7875.pdf"
            }, {
                nome: "LEI NÂº 7.803, DE 18 DE JULHO DE 1989",
                descricao: "Altera a redaÃ§Ã£o da Lei nÂº 4.771, de 15 de setembro de 1965, e revoga as Leis nÂºs 6.535, de 15 de junho de 1978, e 7.511, de 7 de julho de 1986.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/leis/L7803.htm",
                nomeArquivo: "leis/LEI7803.pdf"
            }, {
                nome: "LEI NÂº 7.754, DE 14 DE ABRIL DE 1989",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/leis/L7754.htm",
                nomeArquivo: "leis/LEI7754.pdf"
            }, {
                nome: "DECRETO NÂº 97.628, DE 10 DE ABRIL DE 1989",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/decreto/1980-1989/D97628.htm",
                nomeArquivo: "leis/DECRETO97628.pdf"
            }, {
                nome: "DECRETO NÂº 97.635, DE 10 DE ABRIL DE 1989",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/decreto/1980-1989/D97635.htm",
                nomeArquivo: "leis/DECRETO97635.pdf"
            }, {
                nome: "LEI NÂº 7.511, DE 7 DE JULHO DE 1986",
                descricao: "Altera dispositivos da Lei nÂº 4.771, de 15 de setembro de 1965, que institui o novo CÃ³digo Florestal.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/leis/L7511.htm",
                nomeArquivo: "leis/LEI7511.pdf"
            }, {
                nome: "LEI NÂº 6.535, DE 15 DE JUNHO DE 1978",
                descricao: "",
                linkSite: "http://www.planalto.gov.br/ccivil_03/leis/L6535.htm",
                nomeArquivo: "leis/LEI6535.pdf"
            }, {
                nome: "LEI NÂº 5.870, DE 26 DE MARÃ‡O DE 1973",
                descricao: "Acrescenta alÃ­nea ao artigo 26 da Lei nÂº 4.771, de 15 de setembro 1965, que institui o novo CÃ³digo Florestal.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/leis/1970-1979/L5870.htm",
                nomeArquivo: "leis/LEI5870.pdf"
            }, {
                nome: "LEI NÂº 5.868, DE 12 DE DEZEMBRO DE 1972",
                descricao: "Cria o Sistema Nacional de Cadastro Rural, e dÃ¡ outras providÃªncias.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/leis/L5868.htm",
                nomeArquivo: "leis/LEI5868.pdf"
            }, {
                nome: "LEI NÂº 4.771, DE 15 DE SETEMBRO DE 1965",
                descricao: "Institui o novo CÃ³digo Florestal.",
                linkSite: "http://www.planalto.gov.br/ccivil_03/leis/L4771.htm",
                nomeArquivo: "leis/LEI4771.pdf"
            }, {
                nome: "DECRETO NÂº 23.793, DE 23 DE JANEIRO DE 1934",
                descricao: "Aprova o codigo florestal que com este baixa",
                linkSite: "http://www.planalto.gov.br/ccivil_03/decreto/1930-1949/d23793.htm",
                nomeArquivo: "leis/DECRETO23793.pdf"
            } ];
            $(window).scroll(function() {
                if ($(this).scrollTop() > 200) {
                    $(".goToTop").fadeIn();
                } else {
                    $(".goToTop").fadeOut();
                }
            });
            $(".goToTop").click(function() {
                $("html, body").animate({
                    scrollTop: 0
                }, 1e3);
                return false;
            });
        } ]);
    })();
    (function() {
        String.prototype.isEmail = function() {
            var emailAddress = this.toString();
            var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
            return pattern.test(emailAddress);
        };
        String.prototype.isCPF = function() {
            var cpf = this.toString().replace(/[-_.\/]/g, "");
            var soma;
            var resto;
            var i;
            if (cpf === null || cpf === undefined || cpf.length !== 11 || cpf === "00000000000" || cpf === "11111111111" || cpf === "22222222222" || cpf === "33333333333" || cpf === "44444444444" || cpf === "55555555555" || cpf === "66666666666" || cpf === "77777777777" || cpf === "88888888888" || cpf === "99999999999") {
                return false;
            }
            soma = 0;
            for (i = 1; i <= 9; i++) {
                soma += Math.floor(cpf.charAt(i - 1)) * (11 - i);
            }
            resto = 11 - (soma - Math.floor(soma / 11) * 11);
            if (resto === 10 || resto === 11) {
                resto = 0;
            }
            if (resto !== Math.floor(cpf.charAt(9))) {
                return false;
            }
            soma = 0;
            for (i = 1; i <= 10; i++) {
                soma += cpf.charAt(i - 1) * (12 - i);
            }
            resto = 11 - (soma - Math.floor(soma / 11) * 11);
            if (resto === 10 || resto === 11) {
                resto = 0;
            }
            if (resto !== Math.floor(cpf.charAt(10))) {
                return false;
            }
            return true;
        };
        String.prototype.isCNPJ = function() {
            var cnpj = this.toString().replace(/[-_.\/]/g, "");
            if (cnpj === null || cnpj === undefined || cnpj.length !== 14) {
                return false;
            }
            var i;
            var c = cnpj.substr(0, 12);
            var dv = cnpj.substr(12, 2);
            var d1 = 0;
            for (i = 0; i < 12; i++) {
                d1 += c.charAt(11 - i) * (2 + i % 8);
            }
            if (d1 === 0) {
                return false;
            }
            d1 = 11 - d1 % 11;
            if (d1 > 9) {
                d1 = 0;
            }
            if (parseInt(dv.charAt(0), 10) !== d1) {
                return false;
            }
            d1 *= 2;
            for (i = 0; i < 12; i++) {
                d1 += c.charAt(11 - i) * (2 + (i + 1) % 8);
            }
            d1 = 11 - d1 % 11;
            if (d1 > 9) {
                d1 = 0;
            }
            if (parseInt(dv.charAt(1), 10) !== d1) {
                return false;
            }
            return true;
        };
    })();
    (function() {
        var modulo = angular.module("SICAR");
        modulo.service("versaoCadastroService", [ "$http", "config", "requestUtil", function($http, config, requestUtil) {
            var service = {};
            service.versaoCadastro = function(successCallback, errorCallback) {
                requestUtil.get(config.BASE_URL + "/cadastro/versao", successCallback, errorCallback);
            };
            return service;
        } ]);
    })();
})({}, function() {
    return this;
}());
