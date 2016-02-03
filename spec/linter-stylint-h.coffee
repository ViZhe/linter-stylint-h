describe 'The stylint provider for Linter', ->
  lint = require('../lib/init').provideLinter().lint

  beforeEach ->
    atom.workspace.destroyActivePaneItem()
    waitsForPromise ->
      return atom.packages.activatePackage('linter-stylint-h')

  it 'should be in the packages list', ->
    return expect(atom.packages.isPackageLoaded('linter-stylint-h')).toBe true

  it 'should be an active package', ->
    return expect(atom.packages.isPackageActive('linter-stylint-h')).toBe true

  it 'finds nothing wrong with valid files', ->
    waitsForPromise ->
      return atom.workspace.open(__dirname + '/fixtures/good.styl').then (editor) ->
        return lint(editor).then (messages) ->
          expect(messages.length).toEqual 0

  it 'finds something wrong with invalid files', ->
    waitsForPromise ->
      return atom.workspace.open(__dirname + '/fixtures/bad.styl').then (editor) ->
        return lint(editor).then (messages) ->
          expect(messages.length).toEqual 2
