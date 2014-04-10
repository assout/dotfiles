if has('win32')
	" フォント変更
	set guifont=MS_Gothic:h9:cSHIFTJIS
endif

" 縦幅 デフォルトは24
set lines=40
" 横幅 デフォルトは80
set columns=120
" 水平スクロールバーを表示
set guioptions+=b
" メニューバーを非表示
set guioptions-=m
" ツールバーを非表示
set guioptions-=T
" 常にタブラベルを表示する
set showtabline=2

" カラースキーム変更
colorscheme hybrid

