<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>

<body>
    <ul>
        {{ range services }}
        {{ range service .Name }}
        <li>
            {{ .Address }}:{{ .Port }} - {{ .Name }} - {{ .Tags }}
        </li>
        {{ end }}
        {{ end }}
    </ul>
</body>

</html>