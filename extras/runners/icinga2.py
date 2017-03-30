from __future__ import absolute_import
import salt.runner
import salt.pillar
import logging
import cpillar

log = logging.getLogger(__name__)

# def ident():
#     client = salt.client.LocalClient(__opts__['conf_file'])
#     node = client.cmd(pillar.get('defaults:monitor:masters', {})
#     return "I am the icinga2 runner. " + node


def ipillar(domain, saltenv=None, top="1nc"):

    _pillar = cpillar.fake_pillar(domain, saltenv, top, __opts__)

    res = {}
    defaults = _pillar.get('defaults', {})
    nodes = _pillar.get('hosts', {})
    nodes.update(_pillar.get('containers', {}))
    for id, node in nodes.items():
        ip = node.get('ip4')
        active = node.get('active', True)
        mole = node.get('mole', defaults.get('monitor:mole', 'hosts'))
        cpillar.gen_networks(res, id, ip, active, mole, defaults.get('hosts').get('network'), node.get('network'))

    return res


def pki_ticket(target):
    '''
    Retrieve a ticket for a specific minion from the icinga2 master
    to allow the download of files, specifically the certificates

    :param target:
        the fqdn of the minion get the ticket for

    :return:
        the ticket as a string
    '''

    client = salt.client.LocalClient(__opts__['conf_file'])
    ticket_dict = client.cmd('roles:icinga_ca', 'icinga2.ssl_cert_ticket', [target], timeout=1, expr_form='grain')

    source, ticket = ticket_dict.popitem()
    log.info('Read ticket from %s as %s', source, ticket)

    return ticket


def pki_gricket(target):
    '''
    Retrieve the ticket for an icinga node from the icinga2 supermaster and store
    it in the grains of the target node

    :param target:
        Target is the minion you want to set the ticket grain for

    :return:
        Func call return object
    '''

    ticket = pki_ticket(target)
    client = salt.client.LocalClient(__opts__['conf_file'])
    res = client.cmd(target, 'grains.setval', ['icinga_ticket', ticket])
    return res


def cluster_update_request_handler(source, data):
    '''
    This runner will pick up any cluster update requests coming in and
    forward it to the targets mentioned in the data received in the event.

    Keep in mind that this is a bubble up event coming from one original node,
    so it will only about this one node. It means the configuration for only
    this node will be updated on the parent endpoint.

    :param source:
        The minion id of the minion that issued the request (not the node
        that needs to be reconfigured - which is stored in the data)

    :param data:
        Event data payload

    :return:
        A list containing one result object per endpoint call
    '''

    sendto = ','.join(data['publish_endpoints'])
    log.warn('Fire up runner for minion %s, sending to %s', source, sendto)

    # run the config state on all of the listed endpoints
    client = salt.client.LocalClient(__opts__['conf_file'])
    res = client.cmd(data['publish_endpoints'], 'state.sls', ['icinga.instance.host.dummy'],
                     timeout=30, expr_form='list', kwarg={'pillar': data, 'queue': True})

    log.debug('Runner result: %s', res)

    return res


