import { PackageURL } from 'packageurl-js'
import { describe, expect, it } from 'vitest'

import { PackageCache } from './package-cache.js'
import { Package } from './package.js'

const purl = 'pkg:npm/%40khulnasoft/dependency-submission@0.1.2'

describe('PackageCache', () => {
  describe('with no packages', () => {
    const cache = new PackageCache()
    it('adds and remove Package', () => {
      const dep = new Package(purl)
      cache.addPackage(dep)
      expect(cache.countPackages()).toBe(1)
      cache.removePackage(dep)
      expect(cache.countPackages()).toBe(0)
    })
    it('constructs a package with .package using PackageURL', () => {
      const packageURL = new PackageURL(
        'npm',
        'github',
        'dependency-submission',
        '0.1.2',
        null,
        null
      )
      const dep = cache.package(packageURL)
      expect(dep).toBeInstanceOf(Package)
      expect(cache.countPackages()).toBe(1)

      // purposely using reference equality with 'toBe'
      expect(cache.package(packageURL)).toBe(dep)
    })
    it('constructs a package with .package using string', () => {
      const cache = new PackageCache()
      const dep = cache.package(purl)
      expect(dep).toBeInstanceOf(Package)
      expect(cache.countPackages()).toBe(1)

      // purposely using reference equality with 'toBe'
      expect(cache.package(purl)).toBe(dep)
    })
    it('.packagesMatching returns packages that match matcher', () => {
      const cache = new PackageCache()
      cache.package(
        new PackageURL(
          'npm',
          '@khulnasoft',
          'dependency-submission',
          '0.1.2',
          null,
          null
        )
      )

      cache.package(
        new PackageURL(
          'npm',
          '@khulnasoft',
          'dependency-submission',
          '0.2.0',
          null,
          null
        )
      )

      expect(cache.packagesMatching({ namespace: '@khulnasoft' })).toHaveLength(
        2
      )
      expect(cache.packagesMatching({ namespace: '@gubhib' })).toHaveLength(0)

      expect(
        cache.packagesMatching({
          namespace: '@khulnasoft',
          name: 'dependency-submission'
        })
      ).toHaveLength(2)

      expect(
        cache.packagesMatching({
          namespace: '@khulnasoft',
          name: 'dependency-submission',
          version: '0.1.2'
        })
      ).toHaveLength(1)
    })
  })
})
