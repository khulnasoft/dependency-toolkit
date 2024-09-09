import { PackageURL } from 'packageurl-js'
import { describe, expect, it } from 'vitest'

import { Package } from './package.js'

describe('Package', () => {
  it('constructs a from Package URL-formatted string ', () => {
    const purl = 'pkg:npm/%40khulnasoft/dependency-submission@0.1.2'
    const pkg = new Package(purl)

    expect(pkg.namespace()).toBe('@khulnasoft')
    expect(pkg.name()).toBe('dependency-submission')
    expect(pkg.version()).toBe('0.1.2')
  })
  it('constructs a package with from PackageURL object', () => {
    const pkg = new Package(
      new PackageURL(
        'npm',
        '@khulnasoft',
        'dependency-submission',
        '0.1.2',
        null,
        null
      )
    )

    expect(pkg.namespace()).toBe('@khulnasoft')
    expect(pkg.name()).toBe('dependency-submission')
    expect(pkg.version()).toBe('0.1.2')
  })
  it('.matching will match a package with matching aspects', () => {
    const pkg = new Package(
      new PackageURL(
        'npm',
        '@khulnasoft',
        'dependency-submission',
        '0.1.2',
        null,
        null
      )
    )

    expect(pkg.matching({ namespace: '@khulnasoft' })).toBeTruthy()
    expect(pkg.matching({ namespace: 'buhtig@' })).toBeFalsy()

    expect(pkg.matching({ name: 'dependency-submission' })).toBeTruthy()
    expect(pkg.matching({ name: 'foo-bar-baz' })).toBeFalsy()

    expect(pkg.matching({ version: '0.1.2' })).toBeTruthy()
    expect(pkg.matching({ version: '0.1.2' })).toBeTruthy()

    expect(
      pkg.matching({
        namespace: '@khulnasoft',
        name: 'dependency-submission',
        version: '0.1.2'
      })
    ).toBeTruthy()
    expect(
      pkg.matching({
        namespace: 'buhtig@',
        name: 'dependency-submission',
        version: '0.1.2'
      })
    ).toBeFalsy()
    expect(
      pkg.matching({
        namespace: '@khulnasoft',
        name: 'foo-bar-baz',
        version: '0.1.2'
      })
    ).toBeFalsy()
    expect(
      pkg.matching({
        namespace: '@khulnasoft',
        name: 'dependency-submission',
        version: '1.2.3'
      })
    ).toBeFalsy()
  })
})
