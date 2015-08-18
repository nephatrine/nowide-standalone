Remove-Item -Recurse -Force -ErrorAction silentlycontinue nowide
New-Item nowide\nowide -type directory
New-Item nowide\src -type directory
New-Item nowide\test -type directory
Copy-Item ..\boost\nowide\*.hpp nowide\nowide
Copy-Item ..\libs\nowide\src\*.cpp nowide\src
Copy-Item ..\libs\nowide\test\*.cpp nowide\test\
Copy-Item ..\libs\nowide\test\*.hpp nowide\test\
Copy-Item .\*.hpp nowide\nowide\
Get-ChildItem nowide -File -Recurse |
Foreach-Object{
	$content = Get-Content $_.FullName
	$content = $content.replace('BOOST_NOWIDE_', 'NOWIDE_')
	$content = $content.replace('BOOST_', 'NOWIDE_')
	$content = $content.replace('boost::nowide::', 'nowide::')
	$content = $content.replace('boost::nowide', 'nowide')
	$content = $content.replace('boost::locale::', 'nowide::')
	$content = $content.replace('boost::', 'nowide::')
	$content = $content.replace('namespace boost {', '// namespace boost {')
	$content = $content.replace('} // namespace boost', '// } namespace boost')
	$content = $content.replace('<boost/locale/', '<nowide/')
	$content = $content.replace('<boost/nowide/', '<nowide/')
	$content = $content.replace('<boost/', '<nowide/')
	$content | Set-Content $_.FullName
}
Copy-Item CMakeLists.txt nowide\

#sed 's/namespace boost {//' -i $SOURCES
#sed 's/} *\/\/ *namespace boost//' -i $SOURCES
