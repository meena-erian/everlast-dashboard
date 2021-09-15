import React, { FC } from 'react';
//import config from 'app/core/config';
import { Icon, IconName } from '@grafana/ui';

export interface FooterLink {
  text: string;
  icon?: string;
  url?: string;
  target?: string;
}

export let getFooterLinks = (): FooterLink[] => {
  const msgBody = `subject=Everlast%20Dashboard%20Support&body=Issue%20summary%3A%0D%0A%0D%0A%0D%0ASteps%20to%20reproduce%20the%20Issues%3A`;
  return [
    {
      text: 'User Manual  ',
      icon: 'document-info',
      url: 'https://docs.google.com/document/d/1ug-_fAYmfwLhydClra2-KOFAhTTGpfbHOg2oA8ygTdQ/edit?usp=sharing',
      target: '_blank',
    },
    {
      text: 'Support',
      icon: 'question-circle',
      url: 'mailto:dashboard@everlastwellness.com?' + msgBody,
      target: '_blank',
    },
  ];
};

export let getVersionLinks = (): FooterLink[] => {
  //var { buildInfo, licenseInfo } = config;
  //buildInfo.hideVersion = true;
  const links: FooterLink[] = [];
  //const stateInfo = licenseInfo.stateInfo ? ` (${licenseInfo.stateInfo})` : '';

  //links.push({ text: `${buildInfo.edition}${stateInfo}`, url: licenseInfo.licenseUrl });

  //if (buildInfo.hideVersion) {
  //  return links;
  //}

  //links.push({ text: `v${buildInfo.version} (${buildInfo.commit})` });

  //if (false) {
  //  links.push({
  //    text: `New version available!`,
  //    icon: 'download-alt',
  //    url: 'https://grafana.com/grafana/download?utm_source=grafana_footer',
  //    target: '_blank',
  //  });
  //}

  return links;
};

export function setFooterLinksFn(fn: typeof getFooterLinks) {
  getFooterLinks = fn;
}

export function setVersionLinkFn(fn: typeof getFooterLinks) {
  getVersionLinks = fn;
}

export const Footer: FC = React.memo(() => {
  const links = getFooterLinks().concat(getVersionLinks());

  return (
    <footer className="footer">
      <div className="text-center">
        <ul>
          {links.map(link => (
            <li key={link.text}>
              <a href={link.url} target={link.target} rel="noopener">
                <Icon name={link.icon as IconName} /> {link.text}
              </a>
            </li>
          ))}
        </ul>
      </div>
    </footer>
  );
});
