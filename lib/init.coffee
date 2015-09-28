path = require('path')
helpers = require('atom-linter')

module.exports =
    config:
        executablePath:
            type: 'string'
            default: path.join __dirname, '..', 'node_modules', 'stylint', 'bin', 'stylint'
            description: 'Full path to binary (e.g. /usr/local/bin/stylint)'

        projectConfigFile:
            type: 'string'
            default: '.stylintrc'
            description: 'Relative path from project to config file'

        runWithStrictMode:
            default: false
            title: 'Always run Stylint in \'strict mode\' (config no needed)'
            type: 'boolean'

        onlyRunWhenConfig:
            default: false
            title: 'Run Stylint only if config is found'
            type: 'boolean'

    activate: ->
        require('atom-package-deps').install 'linter-stylint-h'

    provideLinter: ->
        provider =
            grammarScopes: ['source.stylus', 'source.styl']
            scope: 'file'
            lintOnFly: true

            config: (key) ->
                atom.config.get "linter-stylint-h.#{key}"

            lint: (textEditor) ->
                filePath = textEditor.getPath()
                fileText = textEditor.getText()

                onlyRunWhenConfig = @config 'onlyRunWhenConfig'
                runWithStrictMode = @config 'runWithStrictMode'
                executablePath = @config 'executablePath'
                projectConfigFile = @config 'projectConfigFile'

                projectConfigPath = helpers.findFile(atom.project.getPaths()[0], projectConfigFile)

                parameters = []
                parameters.push(filePath)

                if(onlyRunWhenConfig && !projectConfigPath)
                    console.error 'Stylint config no found'
                    return []

                if(onlyRunWhenConfig || !runWithStrictMode && projectConfigPath)
                    parameters.push('-c', projectConfigPath)

                return helpers.execNode(executablePath, parameters, stdin: fileText).then (output) ->
                    regex = '(?<type>(Warning|Error)): (?<message>.*), File: (?<file>.*), Line: (?<line>\\d+):'

                    output = output.replace(/(\r?\n){2}/g,'----')
                    output = output.replace(/(\r?\n){1}/g,', ')
                    output = output.replace(/----/g,'\n')

                    return helpers.parse(output, regex)
